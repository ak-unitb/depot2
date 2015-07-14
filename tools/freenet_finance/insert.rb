
#@identifiers = Identifier.all( :include => :share, :conditions => [ "`identifiers`.`provider` = 'WKN'" ] )

#@identifiers.each { |identifier|
  #filename =  "../data/wkn_".concat(identifier.name).concat("_historic.csv")
  filename = "../../yahoo-finance-api-poll/dax_historisch_table.csv"
  #puts filename
  open(File.expand_path(filename,  __FILE__), "r") { |file|
    fileContent = file.read
    lines = fileContent.split("\n")
    #puts lines.size
    lines.each_with_index { |line, idx|
      if idx != 0
        # Date,Open,High,Low,Close,Volume,Adj Close
        #puts "".concat("1").concat(',').concat(line).split(',')
        h_data = Hash[ [ "stock_exchange_id", "when", "open", "high", "low", "close", "volume", "adj_close" ].zip( "".concat("1").concat(',').concat(line).split(',') ) ]
        #puts idx.to_s.concat(": ").concat(h_data["stock_exchange_id"].to_s).concat(", ").concat(h_data["when"].to_s).concat(", ").concat(h_data["close"].to_s).concat(", ").concat(h_data["adj_close"].to_s)
        sedcp = StockExchangeDailyClosingPrice.new( :when => h_data["when"], :stock_exchange_id => 1, :price => h_data["close"].to_f )
        #puts sedcp.to_s.concat(" : ").concat(sedcp.price.to_f.to_s).concat(" (").concat(h_data["close"].to_f.to_s).concat(")")
        puts sedcp.save()
      end
    }
  }
#}