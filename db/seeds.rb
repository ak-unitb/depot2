# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

stock_exchange = StockExchange.create({ id: 1, name: 'XETRA', closing_time: '18:00:00', timezone: 'GMT+2', location: 'Germany, Frankfurt/Main' })

stock_exchange_daily_closing_prices = StockExchangeDailyClosingPrice.create(
	[
		{ stock_exchange_id: 1,  price: 6048.30, 'when': '2010-01-04' },
		{ stock_exchange_id: 1,  price: 6031.86, 'when': '2010-01-05' },
		{ stock_exchange_id: 1,  price: 6034.33, 'when': '2010-01-06' },
		{ stock_exchange_id: 1,  price: 6019.36, 'when': '2010-01-07' },
		{ stock_exchange_id: 1,  price: 6037.61, 'when': '2010-01-08' },
		{ stock_exchange_id: 1,  price: 6040.50, 'when': '2010-01-11' }
	]
)

shares = Share.create(
	[
		{id: 1, isin: 'DE0005190003', name: 'BMW', currency: 'EUR', stock_exchange_id: 1},
		{id: 2, isin: 'DE000ENAG999', name: 'E.ON', currency: 'EUR', stock_exchange_id: 1}
	]
)

portfolio_changes = PortfolioChange.create(
	[
    {share_id: 1, transaction_type: 'buy', quantity: 20, price_per_share: 21.300, total_cost_of_order: -458.59, 'when': '2008-10-13' },
    {share_id: 2, transaction_type: 'buy', quantity: 32, price_per_share: 28.660, total_cost_of_order: -949.71, 'when': '2008-10-13' },
    {share_id: 2, transaction_type: 'buy', quantity: 63, price_per_share: 15.255, total_cost_of_order: -983.66, 'when': '2011-09-19' }
	]
)

identifiers = Identifier.create(
	[
		{share_id: 1, name: 'BMW', provider: 'XETRA'},
		{share_id: 2, name: 'EOAN', provider: 'XETRA'},
		{share_id: 1, name: 'BMW.DE', provider: 'Finance.Yahoo.com'},
		{share_id: 2, name: 'EOAN.DE', provider: 'Finance.Yahoo.com'},
		{share_id: 1, name: '519000', provider: 'WKN'},
		{share_id: 2, name: 'ENAG99', provider: 'WKN'}
	]
)


daily_closing_prices = DailyClosingPrice.create(
	[
		{share_id: 1, price: 32.05, 'when': '2010-01-04'},
		{share_id: 1, price: 32.31, 'when': '2010-01-05'},
		{share_id: 1, price: 32.81, 'when': '2010-01-06'},
		{share_id: 1, price: 33.10, 'when': '2010-01-07'},
		{share_id: 1, price: 32.65, 'when': '2010-01-08'},
		{share_id: 1, price: 32.17, 'when': '2010-01-11'},
		{share_id: 2, price: 29.27, 'when': '2010-01-04'},
		{share_id: 2, price: 29.29, 'when': '2010-01-05'},
		{share_id: 2, price: 29.17, 'when': '2010-01-06'},
		{share_id: 2, price: 28.93, 'when': '2010-01-07'},
		{share_id: 2, price: 29.23, 'when': '2010-01-08'},
		{share_id: 2, price: 29.36, 'when': '2010-01-11'}
	]
)
