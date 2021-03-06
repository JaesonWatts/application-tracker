class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  def authentication_required
    if !logged_in?
      redirect_to login_path
    end
  end

  helper_method :authentication_required

  def logged_in?
    !!current_user
  end
  helper_method :logged_in?

  def current_user        
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user
end
