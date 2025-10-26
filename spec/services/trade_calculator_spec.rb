require 'rails_helper'

RSpec.describe TradeCalculator do
  let(:user) { create(:user) }
  let!(:portfolio) { create(:portfolio, user: user, total_value: 10000) }
  let(:trade) { create(:trade, user: user, entry_price: 100, quantity: 10, stop_loss: 95) }
  let(:calculator) { described_class.new(trade) }

  describe '#calculate_pnl' do
    context 'with exit price provided' do
      it 'calculates profit correctly' do
        expect(calculator.calculate_pnl(110)).to eq(100)
      end

      it 'calculates loss correctly' do
        expect(calculator.calculate_pnl(90)).to eq(-100)
      end
    end

    context 'without exit price' do
      let(:trade) { create(:trade, :closed_profitable) }

      it 'uses trade exit price' do
        expect(calculator.calculate_pnl).to eq(trade.pnl)
      end
    end

    context 'with missing data' do
      let(:trade) { build(:trade, entry_price: nil) }
      let(:calculator) { described_class.new(trade) }

      it 'returns 0' do
        expect(calculator.calculate_pnl(110)).to eq(0)
      end
    end
  end

  describe '#calculate_percentage_return' do
    let(:trade) { create(:trade, entry_price: 100, stop_loss: 95, quantity: 2, position_size: 200) }

    it 'calculates percentage return correctly' do
      expect(calculator.calculate_percentage_return(110)).to eq(10.0) # 20 profit / 200 position = 10%
    end

    context 'with very small position size' do
      let(:trade) { build(:trade, position_size: 0.01, entry_price: 100, quantity: 1, pnl: nil) }
      let(:calculator) { described_class.new(trade) }

      it 'handles edge case' do
        # Since this is testing the calculator method directly, pnl is calculated
        pnl = calculator.calculate_pnl(110) # 10 * 1 = 10
        percentage = (pnl / 0.01 * 100).round(2)
        expect(calculator.calculate_percentage_return(110)).to eq(percentage)
      end
    end
  end

  describe '#calculate_risk_reward_ratio' do
    it 'calculates risk reward ratio correctly' do
      # Risk: (100 - 95) * 10 = 50
      # Potential reward: estimated at 2:1 ratio = 100
      # Ratio: 100 / 50 = 2.0
      expect(calculator.calculate_risk_reward_ratio).to eq(2.0)
    end

    context 'without stop loss' do
      let(:trade) { create(:trade, :no_stop_loss) }

      it 'returns 0' do
        expect(calculator.calculate_risk_reward_ratio).to eq(0)
      end
    end
  end

  describe '#validate_position_size' do
    context 'when position is within limit' do
      let(:trade) { create(:trade, user: user, position_size: 400) } # 4%

      it 'returns true' do
        expect(calculator.validate_position_size(user)).to be true
      end
    end

    context 'when position exceeds limit' do
      let(:trade) { build(:trade, user: user, position_size: 600) } # 6%
      let(:calculator) { described_class.new(trade) }

      it 'returns false' do
        expect(calculator.validate_position_size(user)).to be false
      end
    end
  end

  describe '#validate_stop_loss' do
    context 'when stop loss is below entry price' do
      it 'returns true' do
        expect(calculator.validate_stop_loss).to be true
      end
    end

    context 'when stop loss is above entry price' do
      let(:trade) { build(:trade, entry_price: 100, stop_loss: 105) }
      let(:calculator) { described_class.new(trade) }

      it 'returns false' do
        expect(calculator.validate_stop_loss).to be false
      end
    end

    context 'when stop loss is missing' do
      let(:trade) { create(:trade, :no_stop_loss) }

      it 'returns false' do
        expect(calculator.validate_stop_loss).to be false
      end
    end
  end

  describe '#calculate_optimal_position_size' do
    let(:trade) { create(:trade, entry_price: 100, stop_loss: 95) }

    it 'calculates optimal position size based on risk' do
      # Risk 1% of $10,000 = $100
      # Risk per share = $100 - $95 = $5
      # Optimal quantity = $100 / $5 = 20 shares
      expect(calculator.calculate_optimal_position_size(user, 0.01)).to eq(20)
    end

    context 'with custom risk percentage' do
      it 'calculates with different risk percentage' do
        # Risk 2% of $10,000 = $200
        # Risk per share = $5
        # Optimal quantity = $200 / $5 = 40 shares
        expect(calculator.calculate_optimal_position_size(user, 0.02)).to eq(40)
      end
    end

    context 'when stop loss equals entry price' do
      let(:trade) { build(:trade, entry_price: 100, stop_loss: 100) }
      let(:calculator) { described_class.new(trade) }

      it 'returns 0' do
        expect(calculator.calculate_optimal_position_size(user)).to eq(0)
      end
    end
  end

  describe '#update_trade_with_exit!' do
    let(:trade) { create(:trade, user: user) }

    before do
      allow(XpEngine).to receive(:new).and_return(double(award_trade_xp: nil))
    end

    it 'updates trade with exit information' do
      calculator.update_trade_with_exit!(110, 'profit_target')

      trade.reload
      expect(trade.exit_price).to eq(110)
      expect(trade.exit_date).to be_present
      expect(trade.status).to eq('closed')
      expect(trade.pnl).to be_present
    end

    it 'awards XP for the trade' do
      xp_engine = double(award_trade_xp: nil)
      allow(XpEngine).to receive(:new).with(user).and_return(xp_engine)

      calculator.update_trade_with_exit!(110)

      expect(xp_engine).to have_received(:award_trade_xp).with(trade)
    end
  end
end