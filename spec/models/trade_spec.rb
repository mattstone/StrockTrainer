require 'rails_helper'

RSpec.describe Trade, type: :model do
  describe 'validations' do
    subject { build(:trade) }

    it { should validate_presence_of(:symbol) }
    it { should validate_presence_of(:entry_price) }
    it { should validate_numericality_of(:entry_price).is_greater_than(0) }
    it { should validate_numericality_of(:position_size).is_greater_than(0) }
    it { should validate_presence_of(:quantity) }
    it { should validate_numericality_of(:quantity).is_greater_than(0) }
    it { should validate_inclusion_of(:status).in_array(%w[pending open closed]) }
    it { should validate_presence_of(:market_view) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:lesson).optional }
    it { should belong_to(:stock).optional }
  end

  describe 'callbacks' do
    describe 'before_validation on create' do
      let(:trade) { build(:trade, status: nil, entry_date: nil) }

      it 'sets default values' do
        trade.save
        expect(trade.status).to eq('pending')
        expect(trade.entry_date).to be_present
      end
    end
  end

  describe 'scopes' do
    let!(:profitable_trade) { create(:trade, :closed_profitable) }
    let!(:losing_trade) { create(:trade, :closed_loss) }
    let!(:open_trade) { create(:trade) }

    describe '.profitable' do
      it 'returns only profitable trades' do
        expect(Trade.profitable).to contain_exactly(profitable_trade)
      end
    end

    describe '.closed' do
      it 'returns only closed trades' do
        expect(Trade.closed).to contain_exactly(profitable_trade, losing_trade)
      end
    end

    describe '.open' do
      it 'returns only open trades' do
        expect(Trade.open).to contain_exactly(open_trade)
      end
    end
  end

  describe '#profitable?' do
    context 'when trade has positive PnL' do
      let(:trade) { create(:trade, :closed_profitable) }

      it 'returns true' do
        expect(trade.profitable?).to be true
      end
    end

    context 'when trade has negative PnL' do
      let(:trade) { create(:trade, :closed_loss) }

      it 'returns false' do
        expect(trade.profitable?).to be false
      end
    end

    context 'when trade has no PnL' do
      let(:trade) { create(:trade, pnl: nil) }

      it 'returns false' do
        expect(trade.profitable?).to be false
      end
    end
  end

  describe '#close_trade!' do
    let(:trade) { create(:trade, entry_price: 100, stop_loss: 95, quantity: 2, position_size: 200) }

    it 'closes the trade with exit price' do
      trade.close_trade!(110)

      expect(trade.exit_price).to eq(110)
      expect(trade.exit_date).to be_present
      expect(trade.pnl).to eq(20) # (110 - 100) * 2
      expect(trade.status).to eq('closed')
    end
  end

  describe '#calculate_pnl' do
    let(:trade) { create(:trade, entry_price: 100, stop_loss: 95, quantity: 2, position_size: 200) }

    context 'with exit price provided' do
      it 'calculates profit and loss' do
        expect(trade.calculate_pnl(110)).to eq(20) # (110 - 100) * 2
      end
    end

    context 'with trade exit price' do
      let(:trade) { create(:trade, :closed_profitable) }

      it 'uses trade exit price' do
        expect(trade.calculate_pnl).to eq(trade.pnl)
      end
    end

    context 'without prices' do
      let(:trade) { build(:trade, entry_price: nil) }

      it 'returns 0' do
        expect(trade.calculate_pnl(110)).to eq(0)
      end
    end
  end

  describe '#percentage_return' do
    let(:trade) { create(:trade, position_size: 400, pnl: 40) }

    it 'calculates percentage return' do
      expect(trade.percentage_return).to eq(10.0)
    end

    context 'when position size is very small' do
      let(:trade) { build(:trade, position_size: 0.01) }

      it 'handles small position size' do
        trade.pnl = 0
        expect(trade.percentage_return).to eq(0)
      end
    end
  end

  describe '#risk_reward_ratio' do
    let(:trade) { create(:trade, entry_price: 100, stop_loss: 95, quantity: 10, pnl: 100) }

    it 'calculates risk reward ratio' do
      expect(trade.risk_reward_ratio).to eq(2.0) # 100 profit / 50 risk
    end

    context 'without stop loss' do
      let(:trade) { create(:trade, :no_stop_loss) }

      it 'returns 0' do
        expect(trade.risk_reward_ratio).to eq(0)
      end
    end
  end

  describe '#duration_in_days' do
    let(:entry_time) { 3.days.ago }
    let(:exit_time) { 1.day.ago }
    let(:trade) { create(:trade, entry_date: entry_time, exit_date: exit_time) }

    it 'calculates duration in days' do
      expect(trade.duration_in_days).to be_within(0.1).of(2.0)
    end

    context 'without exit date' do
      let(:trade) { create(:trade, exit_date: nil) }

      it 'returns 0' do
        expect(trade.duration_in_days).to eq(0)
      end
    end
  end

  describe 'validations' do
    describe 'stop_loss_validation' do
      context 'when stop loss is valid' do
        let(:trade) { build(:trade, entry_price: 100, stop_loss: 95) }

        it 'is valid' do
          expect(trade).to be_valid
        end
      end

      context 'when stop loss is above entry price' do
        let(:trade) { build(:trade, entry_price: 100, stop_loss: 105) }

        it 'adds error' do
          trade.valid?
          expect(trade.errors[:stop_loss]).to include('must be less than entry price for long positions')
        end
      end
    end

    describe 'position_size_limit' do
      let(:user) { create(:user) }
      let!(:portfolio) { create(:portfolio, user: user, total_value: 10000) }

      context 'when position is within limit' do
        let(:trade) { build(:trade, user: user, position_size: 400) } # 4%

        it 'is valid' do
          expect(trade).to be_valid
        end
      end

      context 'when position exceeds limit' do
        let(:trade) { build(:trade, user: user, position_size: 600) } # 6%

        it 'adds error' do
          trade.valid?
          expect(trade.errors[:position_size]).to include('cannot exceed 5% of total portfolio value')
        end
      end
    end
  end

  describe 'after_update callback' do
    let(:user) { create(:user, total_trades: 5, profitable_trades: 3, current_streak: 2) }
    let(:trade) { create(:trade, user: user) }

    context 'when trade becomes profitable' do
      it 'updates user stats' do
        trade.update!(status: 'closed', pnl: 100)

        user.reload
        expect(user.total_trades).to eq(6)
        expect(user.profitable_trades).to eq(4)
        expect(user.current_streak).to eq(3)
      end
    end

    context 'when trade becomes a loss' do
      it 'resets current streak' do
        trade.update!(status: 'closed', pnl: -100)

        user.reload
        expect(user.total_trades).to eq(6)
        expect(user.profitable_trades).to eq(3)
        expect(user.current_streak).to eq(0)
      end
    end
  end
end
