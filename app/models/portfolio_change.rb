class PortfolioChange < ActiveRecord::Base
  belongs_to :share

  has_one :first_buy, -> { where("transaction_type = 'buy'").order('`date_of_day` ASC') }, class_name: 'PortfolioChange'

  def total_value
    quantity * price_per_share
  end

  def value_of_taxes_absolute
    - ( total_cost_of_order + total_value )
  end

  def value_of_taxes_in_percent
    if total_value != 0
      value_of_taxes_absolute / ( total_value / 100 )
    else
      0
    end
  end

end
