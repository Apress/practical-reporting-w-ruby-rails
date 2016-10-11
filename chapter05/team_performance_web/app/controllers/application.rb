# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_team_performance_web_session_id'
  protect_from_forgery # :secret => '5946bdaf4fb685c582d0e732d4bcfb1d'
end
