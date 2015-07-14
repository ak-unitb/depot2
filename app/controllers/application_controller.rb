class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :instantiate_controller_and_action_names
  # http://guides.rubyonrails.org/caching_with_rails.html
  #   you will need to add actionpack-page_caching and actionpack-action_caching to your Gemfile.
  #caches_action :instantiate_controller_and_action_names

  def instantiate_controller_and_action_names
    @current_action = action_name
    @current_controller = controller_name
    @shares = Share::sorted_by_name_isin
  end

  def toCalculatableNumeric(input)
    input.gsub('.', '').gsub(',', '.')
  end

end
