class DailyClosingPrice < ActiveRecord::Base
  belongs_to :share

  validates_uniqueness_of :share_id, :scope => :when

  @previous = nil

  def previous
    if @previous.nil?
      #@previous = DailyClosingPrice.first(:conditions => ["daily_closing_prices.when < ? AND daily_closing_prices.share_id = ?", self.when, share_id], :order => "daily_closing_prices.when DESC", :limit => 1 )
      @previous = DailyClosingPrice.where("`when` < ? AND share_id = ?", self.when, share_id).order('`when` DESC').first;
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
