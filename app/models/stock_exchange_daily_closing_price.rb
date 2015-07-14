class StockExchangeDailyClosingPrice < ActiveRecord::Base
  belongs_to :stockExchange
  validates_uniqueness_of :stock_exchange_id, :scope => :when, :message => "Tagesschlußkurs für das Datum und der ausgewählten Börse schon vorhanden."

  @previous = nil

  def previous
    if @previous.nil?
      @previous = StockExchangeDailyClosingPrice.where("`when` < ? AND stock_exchange_id = ?", self.when, stock_exchange_id).order('`when` DESC').first;
    else
      @previous
    end
  end

  def change_to_previous_absolute
    if not previous.nil?
      - (previous.price - self.price)
    else
      "<N/A>"
    end
  end

  def change_to_previous_in_percent
    if not previous.nil?
      self.price / ( previous.price / 100 ) - 100
    else
      "<N/A>"
    end
  end

end
