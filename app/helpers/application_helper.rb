module ApplicationHelper

  def css_class_for_numeric_value(number)
    css_class = case
    when number < 0
      "negative"
    else
      "positive"
    end
  end
	
end
