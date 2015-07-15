class StockExchangeDailyClosingPrice < ActiveRecord::Base
  belongs_to :stock_exchange
  validates_uniqueness_of :stock_exchange_id, :scope => :date_of_day, :message => "Tagesschlußkurs für das Datum und der ausgewählten Börse schon vorhanden."

  @previous = nil

  def previous
    if @previous.nil?
      @previous = StockExchangeDailyClosingPrice.where("`date_of_day` < ? AND stock_exchange_id = ?", self.date_of_day, stock_exchange_id).order('`date_of_day` DESC').first;
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
