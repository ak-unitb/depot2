
require 'net/http'
# rails 3.1.1: Identifier.all( :include => :share, :conditions => [ "`identifiers`.`provider` = 'Finance.Yahoo.com'" ] )
@identifiers = Identifier.where(provider: 'Finance.Yahoo.com')

#puts @identifiers

@now = Time.now

@filenamesUrls = {}

@identifiers.each { |identifier|
  filename =  "../data/".concat(identifier.share.name_isin).concat("__").concat(identifier.name).concat("__").concat( @now.to_s( :db ) ).gsub(/ /, '_').gsub(/\:/, '_').concat('.csv')
  url = "/d/quotes.csv?s=".concat(identifier.name).concat("&f=sd1l1&e=.csv")
  puts identifier.share.name_isin
  puts identifier.share.id
  @filenamesUrls[ filename ] = { "url" => url, "share_id" => "".concat(identifier.share.id.to_s) }
  puts @filenamesUrls[ filename ].inspect
}

puts @filenamesUrls.inspect

@data = {}

@filenamesUrls.each { |filename, url_share_id|
  puts "about to download http://download.finance.yahoo.com"+url_share_id["url"]
  Net::HTTP.start("download.finance.yahoo.com") { |http|
    resp = http.get( url_share_id[ "url" ] )
    open(File.expand_path(filename,  __FILE__), "wb") { |file|
      file.write(resp.body)
      puts "wrote file "+filename
    }
    @data[ url_share_id[ "share_id" ].to_s ] = resp.body
  }
}

puts @data.inspect



@data.each { |share_id, data|
  h_data = Hash[ [ "share_id", "identifier", "when", "price" ].zip( "".concat(share_id).concat(',').concat(data).split(',') ) ]
  puts h_data;
  identifier = h_data.delete("identifier")
  puts h_data["when"]
  h_data["when"] = Date.strptime(h_data["when"], '"%m/%d/%Y"')
  daily_closing_price = DailyClosingPrice.new( h_data )
  puts daily_closing_price
  puts daily_closing_price.inspect
  puts
  daily_closing_price.save
}

@data = {}

Net::HTTP.start("download.finance.yahoo.com") { |http|
  # "/d/quotes.csv?s=^GDAXI&f=sd1l1&e=.csv"
  resp = http.get( "/d/quotes.csv?s=^GDAXI&f=sd1l1&e=.csv" )
  open(File.expand_path("../data/".concat("DAX-INDEX").concat("__").concat("GDAXI").concat("__").concat( @now.to_s( :db ) ).gsub(/ /, '_').gsub(/\:/, '_').concat('.csv'),  __FILE__), "wb") { |file|
    file.write(resp.body)
  }
  @data[ "DAX" ] = resp.body
}


@data.each { |name, data|
  h_data = Hash[ [ "stock_exchange_id", "identifier", "when", "price" ].zip( "1".concat(',').concat(data).split(',') ) ]
  identifier = h_data.delete("identifier")
  h_data["when"] = Date.strptime(h_data["when"], '"%m/%d/%Y"')
  daily_closing_price = StockExchangeDailyClosingPrice.new( h_data )
  puts daily_closing_price
  puts daily_closing_price.inspect
  puts
  daily_closing_price.save
}



puts Time.now

