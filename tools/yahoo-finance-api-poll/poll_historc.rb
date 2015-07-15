
require 'net/http'
require 'logger'

def ask message
  print message
  STDIN.gets.chomp
end

LOG = Logger.new('poll-historic.log')
LOG.level = Logger::DEBUG # DEBUG, INFO, WARN, ERROR, FATAL, or UNKNOWN
LOG.progname = "Poll-Historic"
LOG.datetime_format = :db

@identifiers = Identifier.all( :include => :share, :conditions => [ "`identifiers`.`provider` = 'Finance.Yahoo.com'" ] )

#puts @identifiers

@now = Time.now

puts "#################################################################"
puts "########## Yahoo-Finance historical share data updater ##########"
puts "#################################################################"

@from = ask("From which date the share data should be processed? [default: 2008-10-01]")
if @from == ""
  @from = "2008-09-01".to_time # Yahoo-Finance-API months starting at 0
  #@from = "2012-09-01".to_time
else
  @from = @from.to_time
end
LOG.debug("@from: "+@from.to_s)
puts "Debug: @from: "+@from.to_s

@to = ask("To which date the share data should be processd? [default: now]")
if @to == ""
  @to = @now
else
  @to = @to.to_time
end

puts
puts "- Preparing the necessary information"

@filenamesUrls = {}
@identifiers.each { |identifier|
  filename =  "../data/historic/".concat(identifier.share.name_isin).concat("__").concat(identifier.name).concat("__").concat( @from.to_s( :db ) ).concat("_to_").concat( @to.to_s( :db ) ).gsub(/ /, '_').gsub(/\:/, '_').concat('.csv')
  url = "/table.csv?s=".concat(identifier.name).concat( "&b=%s&a=%s&c=%d&g=d"%[@from.day, @from.month-1, @from.year] )
  if @to != @now
    url = url.concat( "&e=%s&d=%s&f=%d"%[@to.day, @to.month-1, @to.year] )
  end
  @filenamesUrls[ filename ] = { "url" => url, "share_id" => "".concat(identifier.share.id.to_s) }
  LOG.debug(filename.concat(": ".concat(@filenamesUrls[ filename ].inspect)))
}


print "- Downloading the datas from Yahoo Finance "
@data = {}
@filenamesUrls.each { |filename,url_share_id|
  LOG.debug("about to download http://ichart.finance.yahoo.com"+url_share_id["url"])
  Net::HTTP.start("ichart.finance.yahoo.com") { |http|
    resp = http.get( url_share_id[ "url" ] )
    open(File.expand_path(filename,  __FILE__), "wb") { |file|
      file.write(resp.body)
      LOG.debug("wrote file "+filename)
      print " . "
    }
    @data[ url_share_id[ "share_id" ].to_s ] = resp.body
  }
}

puts

@data.each { |share_id,data|
  lineCounter = 0
  puts
  puts "- Processing data for " + Share.find(share_id).name_isin + " "
  data.each { |line|
    LOG.debug("\n\n" + Share.find(share_id).name_isin)
    LOG.debug(lineCounter.to_s+": "+line)
    if lineCounter > 0
      dataHashed = Hash[ [ "share_id", "date_of_day", "open", "high", "low", "close", "volume", "adj_close" ].zip( "".concat(share_id).concat(',').concat(line.chomp).split(',') ) ]
      LOG.debug(dataHashed.inspect)
      dataPrice = BigDecimal.new(dataHashed["close"])
      LOG.debug(dataPrice.inspect)

      existingDailyClosingPrice = DailyClosingPrice.find_by_date_of_day_and_share_id( dataHashed["date_of_day"], share_id )
      if existingDailyClosingPrice == nil
        daily_closing_price = DailyClosingPrice.new( {"share_id" => dataHashed["share_id"], "date_of_day" => dataHashed["date_of_day"], "price" => dataHashed["close"] } )
        LOG.debug(daily_closing_price.inspect)
        begin
          daily_closing_price.save!
          LOG.info("Saved "+daily_closing_price.inspect)
          print "."
        rescue => ex
          LOG.fatal(ex.message)
          print "!"
        end
      elsif existingDailyClosingPrice.price != dataHashed["close"] && (dataPrice - existingDailyClosingPrice.price).abs > 0.1
        LOG.warn("The historic closing price ("+dataHashed["close"]+") differ from the already saved one ("+existingDailyClosingPrice.price.to_s+")!")
        LOG.warn("Asking for update: '"+line.chomp+"' for "+existingDailyClosingPrice.share.name+" (ID: "+share_id.to_s+")")
        puts
        puts "The historic closing price ("+dataHashed["close"]+") for "+existingDailyClosingPrice.share.name+" from the "+dataHashed["date_of_day"]+" differ from the already saved one ("+existingDailyClosingPrice.price.to_s+")!"
        decision = ask('Should the DailyClosingPrice be updated with the new price? [y/N]')
        if decision == "y"
          existingDailyClosingPrice.price = dataPrice
          begin
            existingDailyClosingPrice.update!
            LOG.info("Updated "+existingDailyClosingPrice.inspect+" -> price now: "+existingDailyClosingPrice.price.to_s+" historical: "+dataPrice.to_s)
            print "."
          rescue => ex
            LOG.fatal(ex.message)
            print "!"
          end
        else
          LOG.warn("NOT updated by user's decision: "+existingDailyClosingPrice.inspect+" skipped price: "+dataPrice.to_s+" (still: "+existingDailyClosingPrice.price.to_s+")")
          print "^"
        end
      elsif existingDailyClosingPrice.price != dataPrice && (dataPrice - existingDailyClosingPrice.price).abs <= 0.1
        LOG.warn("The historic closing price ("+dataHashed["close"]+") differ from the already saved one ("+existingDailyClosingPrice.price.to_s+")! Didn't save '"+line.chomp+"' for "+existingDailyClosingPrice.share.name+" (ID: "+share_id.to_s+")")
        print "="
      else
        LOG.info("Already exists for ("+existingDailyClosingPrice.share.name+" [ID: "+share_id.to_s+"]): "+line)
        print "_"
      end
    end
    lineCounter+=1
  }
  puts
}

puts
puts "Done!"
