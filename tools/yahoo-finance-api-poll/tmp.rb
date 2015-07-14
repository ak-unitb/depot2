
require 'net/http'

@identifiers = Identifier.all( :include => :share, :conditions => [ "`identifiers`.`provider` = 'Finance.Yahoo.com'" ] )

#puts @identifiers

@now = Time.now

@filenamesUrls = {}

@identifiers.each { |identifier|
  filename =  "../data/".concat(identifier.share.name_isin).concat("__").concat(identifier.name).concat("__").concat( @now.to_s( :db ) ).gsub(/ /, '_').gsub(/\:/, '_').concat('.csv')
  url = "/d/quotes.csv?s=".concat(identifier.name).concat("&f=sd1l1&e=.csv")
  #puts identifier.share.name_isin
  #puts identifier.share.id
  @filenamesUrls[ filename ] = { "url" => url, "share_id" => "".concat(identifier.share.id.to_s) } 
}

#puts @filenamesUrls.inspect

@data = {}

@filenamesUrls.each { |filename,url_share_id|
  Net::HTTP.start("download.finance.yahoo.com") { |http|
    resp = http.get( url_share_id[ "url" ] )
    @data[ url_share_id[ "share_id" ].to_s ] = resp.body
  }
}

@data.each { |share_id,data|
  #puts "".concat(k).concat(": ").concat(v)
  h_data = Hash[ [ "share_id", "identifier", "when", "price" ].zip( "".concat(share_id).concat(',').concat(data).split(',') ) ]
  identifier = h_data.delete("identifier")
  daily_closing_price = DailyClosingPrice.new( h_data )
  #puts daily_closing_price
  #puts daily_closing_price.inspect
  #puts
  daily_closing_price.save
}
