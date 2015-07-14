module HomeHelper

  def css_class_for_daily_closing_price(absolute_change_to_previous)
    if absolute_change_to_previous == "<N/A>"
      css_class = "not-available"
    else
      absolute_change_to_previous = absolute_change_to_previous.to_f
      css_class = case
      when absolute_change_to_previous > 0
          case
            when absolute_change_to_previous <= 1
              "plus level-1"
            when absolute_change_to_previous <= 3
              "plus level-2"
            when absolute_change_to_previous <= 6
              "plus level-3"
            when absolute_change_to_previous <= 12
              "plus level-4"
            else
              "plus level-5"
            end
        when absolute_change_to_previous < 0
          case
            when absolute_change_to_previous >= -1
              "minus level-1"
            when absolute_change_to_previous >= -3
              "minus level-2"
            when absolute_change_to_previous >= -6
              "minus level-3"
            when absolute_change_to_previous >= -12
              "minus level-4"
            else
              "minus level-5"
            end
        else
          "equal"
        end
    end
  end

  def css_class_for_relation_current_value_to_costs_in_percent(relation_current_value_to_costs_in_percent)
    css_class = case
    when relation_current_value_to_costs_in_percent >= 200
      "good-extra"
    when relation_current_value_to_costs_in_percent >= 100
      "good"
    when relation_current_value_to_costs_in_percent >= 85
      "bad"
    else
      "bad-extra"
    end
  end

end
