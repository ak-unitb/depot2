class DailyClosingPrice < ActiveRecord::Base
  belongs_to :share

  validates_uniqueness_of :share_id, :scope => :date_of_day

  @previous = nil

  def previous
    if @previous.nil?
      #@previous = DailyClosingPrice.first(:conditions => ["daily_closing_prices.date_of_day < ? AND daily_closing_prices.share_id = ?", self.date_of_day, share_id], :order => "daily_closing_prices.date_of_day DESC", :limit => 1 )
      @previous = DailyClosingPrice.where("`date_of_day` < ? AND share_id = ?", self.date_of_day, share_id).order('`date_of_day` DESC').first;
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
