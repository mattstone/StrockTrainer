require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    subject { build(:user) }

    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }
    it { should validate_numericality_of(:experience_points).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:level).is_greater_than_or_equal_to(1) }
    it { should validate_numericality_of(:current_streak).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:total_trades).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:profitable_trades).is_greater_than_or_equal_to(0) }
    it { should have_secure_password }

    context 'when creating user without defaults' do
      let(:user) { User.new(email: 'test@example.com', password: 'password') }

      it 'validates presence after defaults are set' do
        expect(user).to be_valid
        expect(user.experience_points).to eq(0)
        expect(user.level).to eq(1)
      end
    end
  end

  describe 'associations' do
    it { should have_many(:trades).dependent(:destroy) }
    it { should have_many(:portfolios).dependent(:destroy) }
    it { should have_many(:user_badges).dependent(:destroy) }
    it { should have_many(:badges).through(:user_badges) }
  end

  describe 'callbacks' do
    describe 'before_validation on create' do
      let(:user) { build(:user, experience_points: nil, level: nil) }

      it 'sets default values' do
        user.save
        expect(user.experience_points).to eq(0)
        expect(user.level).to eq(1)
        expect(user.current_streak).to eq(0)
        expect(user.total_trades).to eq(0)
        expect(user.profitable_trades).to eq(0)
      end
    end
  end

  describe '#win_rate' do
    let(:user) { create(:user, total_trades: 10, profitable_trades: 6) }

    it 'calculates win rate percentage' do
      expect(user.win_rate).to eq(60.0)
    end

    context 'when no trades' do
      let(:user) { create(:user, total_trades: 0) }

      it 'returns 0' do
        expect(user.win_rate).to eq(0)
      end
    end
  end

  describe '#next_level_xp' do
    let(:user) { create(:user, level: 5) }

    it 'calculates XP needed for next level' do
      expect(user.next_level_xp).to eq(5000)
    end
  end

  describe '#progress_to_next_level' do
    let(:user) { create(:user, level: 2, experience_points: 1000) }

    it 'calculates progress percentage' do
      expect(user.progress_to_next_level).to eq(50.0)
    end

    context 'when XP exceeds next level requirement' do
      let(:user) { create(:user, level: 1, experience_points: 1500) }

      it 'returns 100%' do
        expect(user.progress_to_next_level).to eq(100)
      end
    end
  end

  describe '#level_up_if_eligible!' do
    let(:user) { create(:user, level: 1, experience_points: 2500) }

    it 'levels up user when eligible' do
      expect { user.level_up_if_eligible! }.to change { user.level }.from(1).to(3)
    end

    context 'when not eligible' do
      let(:user) { create(:user, level: 1, experience_points: 500) }

      it 'does not level up' do
        expect { user.level_up_if_eligible! }.not_to change { user.level }
      end
    end
  end

  describe '#add_experience!' do
    let(:user) { create(:user, experience_points: 900, level: 1) }

    it 'adds experience points' do
      expect { user.add_experience!(200) }.to change { user.experience_points }.by(200)
    end

    it 'triggers level up if eligible' do
      expect { user.add_experience!(200) }.to change { user.level }.from(1).to(2)
    end
  end

  describe '#total_portfolio_value' do
    let(:user) { create(:user) }
    let!(:portfolio1) { create(:portfolio, user: user, total_value: 5000) }
    let!(:portfolio2) { create(:portfolio, user: user, total_value: 3000) }

    it 'sums all portfolio values' do
      expect(user.total_portfolio_value).to eq(8000)
    end
  end
end
