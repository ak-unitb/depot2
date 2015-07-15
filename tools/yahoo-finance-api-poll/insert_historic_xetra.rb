
#@identifiers = Identifier.all( :include => :share, :conditions => [ "`identifiers`.`provider` = 'WKN'" ] )

#@identifiers.each { |identifier|
  #filename =  "../data/wkn_".concat(identifier.name).concat("_historic.csv")
  # http://ichart.finance.yahoo.com/table.csv?s=%5EGDAXI&d=4&e=13&f=2013&g=d&a=10&b=3&c=2011&ignore=.csv
  # http://ichart.finance.yahoo.com/table.csv?s=%5EGDAXI&a=<START_MONTH - 1>&b=<START_DAY>&c=<START_YEAR>&d=<END_MONTH - 1>&e=<END_DAY>&f=<END_YEAR>&g=d&ignore=.csv
  filename = "../data/historic/XETRA_GDAXI__2014-12-08_to_2014-12-12.csv"
  #puts filename
  open(File.expand_path(filename,  __FILE__), "r") { |file|
    fileContent = file.read
    lines = fileContent.split("\n")
    #puts lines.size
    lines.each_with_index { |line, idx|
      if idx != 0
        puts
        puts
        # Date,Open,High,Low,Close,Volume,Adj Close
        #puts "".concat("1").concat(',').concat(line).split(',')
        h_data = Hash[ [ "stock_exchange_id", "date_of_day", "open", "high", "low", "close", "volume", "adj_close" ].zip( "".concat("1").concat(',').concat(line).split(',') ) ]
        #puts idx.to_s.concat(": ").concat(h_data["stock_exchange_id"].to_s).concat(", ").concat(h_data["date_of_day"].to_s).concat(", ").concat(h_data["close"].to_s).concat(", ").concat(h_data["adj_close"].to_s)
        puts "Length ".concat(StockExchangeDailyClosingPrice.find(:all, :conditions => '`date_of_day` = "'.concat(h_data["date_of_day"]).concat('"') ).length.to_s)
        if StockExchangeDailyClosingPrice.find(:all, :conditions => '`date_of_day` = "'.concat(h_data["date_of_day"]).concat('"') ).length == 0
          sedcp = StockExchangeDailyClosingPrice.new( :date_of_day => h_data["date_of_day"], :stock_exchange_id => 1, :price => h_data["close"].to_f )
          puts sedcp.to_s.concat(" : ").concat(sedcp.price.to_f.to_s).concat(" (").concat(h_data["close"].to_f.to_s).concat(")")
          puts sedcp.save()
        else
          puts StockExchangeDailyClosingPrice.find(:all, :conditions => '`date_of_day` = "'.concat(h_data["date_of_day"]).concat('"') ).inspect
        end
      end
    }
  }
#}
