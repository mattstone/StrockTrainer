class MarketDataService
  include HTTParty

  BASE_URL = 'https://query1.finance.yahoo.com/v8/finance/chart'.freeze
  CACHE_DURATION = 15.minutes

  class << self
    def get_stock_price(symbol)
      stock = Stock.find_by(symbol: symbol.upcase)

      # Return cached price if recent
      if stock&.last_updated && stock.last_updated > CACHE_DURATION.ago
        return stock.current_price
      end

      # Fetch new price
      price = fetch_price_from_yahoo(symbol)

      if price
        update_or_create_stock(symbol, price)
        price
      else
        stock&.current_price || generate_mock_price(symbol)
      end
    end

    def get_stock_info(symbol)
      stock = Stock.find_by(symbol: symbol.upcase)

      # For MVP, return basic info
      if stock
        {
          symbol: stock.symbol,
          name: stock.name,
          current_price: stock.current_price,
          sector: stock.sector,
          market_cap: stock.market_cap,
          last_updated: stock.last_updated
        }
      else
        # Return mock data for development
        create_mock_stock(symbol)
      end
    end

    def get_historical_data(symbol, period = '1mo')
      # For MVP, return simulated historical data
      # In production, you'd fetch real data from Yahoo Finance or another provider
      generate_mock_historical_data(symbol, period)
    end

    def update_all_stock_prices
      Stock.all.find_each do |stock|
        begin
          new_price = fetch_price_from_yahoo(stock.symbol)
          stock.update_price!(new_price) if new_price
        rescue => e
          Rails.logger.error "Failed to update price for #{stock.symbol}: #{e.message}"
        end
      end
    end

    private

    def fetch_price_from_yahoo(symbol)
      response = HTTParty.get("#{BASE_URL}/#{symbol.upcase}",
        headers: { 'User-Agent' => 'StockTrainer/1.0' },
        timeout: 10
      )

      if response.success? && response.parsed_response
        chart_data = response.parsed_response.dig('chart', 'result', 0)
        return nil unless chart_data

        # Get the latest close price
        quotes = chart_data.dig('indicators', 'quote', 0, 'close')
        return nil unless quotes&.any?

        quotes.compact.last&.to_f
      else
        nil
      end
    rescue => e
      Rails.logger.error "Yahoo Finance API error for #{symbol}: #{e.message}"
      nil
    end

    def update_or_create_stock(symbol, price)
      stock = Stock.find_or_initialize_by(symbol: symbol.upcase)

      if stock.new_record?
        # Set default values for new stocks
        stock.assign_attributes(
          name: get_company_name(symbol),
          current_price: price,
          sector: 'Technology', # Default sector
          market_cap: rand(1_000_000_000..100_000_000_000),
          last_updated: Time.current
        )
      else
        stock.update_price!(price)
      end

      stock.save!
      stock
    end

    def get_company_name(symbol)
      # In production, you'd fetch this from an API
      # For MVP, using mock names
      company_names = {
        'AAPL' => 'Apple Inc.',
        'GOOGL' => 'Alphabet Inc.',
        'MSFT' => 'Microsoft Corporation',
        'AMZN' => 'Amazon.com Inc.',
        'TSLA' => 'Tesla Inc.',
        'NVDA' => 'NVIDIA Corporation',
        'META' => 'Meta Platforms Inc.',
        'NFLX' => 'Netflix Inc.',
        'SPY' => 'SPDR S&P 500 ETF'
      }

      company_names[symbol.upcase] || "#{symbol.upcase} Corporation"
    end

    def generate_mock_price(symbol)
      # Generate a realistic price based on symbol
      base_prices = {
        'AAPL' => 150,
        'GOOGL' => 120,
        'MSFT' => 300,
        'AMZN' => 140,
        'TSLA' => 200,
        'NVDA' => 400,
        'META' => 280,
        'NFLX' => 380,
        'SPY' => 420
      }

      base_price = base_prices[symbol.upcase] || rand(50..500)
      # Add some random variation
      base_price + rand(-5.0..5.0)
    end

    def create_mock_stock(symbol)
      price = generate_mock_price(symbol)

      stock = Stock.create!(
        symbol: symbol.upcase,
        name: get_company_name(symbol),
        current_price: price,
        sector: ['Technology', 'Healthcare', 'Finance', 'Energy', 'Consumer'].sample,
        market_cap: rand(1_000_000_000..100_000_000_000),
        last_updated: Time.current
      )

      {
        symbol: stock.symbol,
        name: stock.name,
        current_price: stock.current_price,
        sector: stock.sector,
        market_cap: stock.market_cap,
        last_updated: stock.last_updated
      }
    end

    def generate_mock_historical_data(symbol, period)
      days = case period
             when '1d' then 1
             when '5d' then 5
             when '1mo' then 30
             when '3mo' then 90
             when '1y' then 365
             else 30
             end

      current_price = get_stock_price(symbol)
      data = []

      days.times do |i|
        date = days.days.ago + i.days
        # Generate realistic price movement
        change = rand(-2.0..2.0)
        price = current_price * (1 + change / 100)

        data << {
          date: date.to_date,
          open: price + rand(-1.0..1.0),
          high: price + rand(0..3.0),
          low: price - rand(0..3.0),
          close: price,
          volume: rand(1_000_000..10_000_000)
        }
      end

      data.sort_by { |d| d[:date] }
    end
  end
end