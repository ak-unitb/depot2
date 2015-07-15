
require 'net/http'

@identifiers = Identifier.all( :include => :share, :conditions => [ "`identifiers`.`provider` = 'Finance.Yahoo.com'" ] )

#puts @identifiers

@now = Time.now

@filenamesUrls = {}

@identifiers.each { |identifier|
  filename =  "../data/historic/".concat(identifier.share.name_isin).concat("__").concat(identifier.name).concat("__").concat( @now.to_s( :db ) ).gsub(/ /, '_').gsub(/\:/, '_').concat('.csv')
  url = "/table.csv?s==".concat(identifier.name).concat("&a=0&b=1&c=2012&g=d")
  #puts identifier.share.name_isin
  #puts identifier.share.id
  @filenamesUrls[ filename ] = { "url" => url, "share_id" => "".concat(identifier.share.id.to_s) }
  puts @filenamesUrls[ filename ]
}

#puts @filenamesUrls.inspect

@data = {}

@filenamesUrls.each { |filename,url_share_id|
  Net::HTTP.start("ichart.finance.yahoo.com") { |http|
    resp = http.get( url_share_id[ "url" ] )
    open(File.expand_path(filename,  __FILE__), "wb") { |file|
      file.write(resp.body)
    }
    @data[ url_share_id[ "share_id" ].to_s ] = resp.body
  }
}

@data.each { |share_id,data|
  h_data = Hash[ [ "share_id", "date_of_day", "open", "high", "low", "close", "volume", "adj_close" ].zip( "".concat(share_id).concat(',').concat(data).split(',') ) ]
  puts h_data
  #daily_closing_price = DailyClosingPrice.new( h_data )
  #puts daily_closing_price
  #puts daily_closing_price.inspect
  #puts
  #daily_closing_price.save
}
