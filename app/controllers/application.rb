# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  
  layout 'application'

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '0def5fe96b12d02ab60f80a5b7a86ba2'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  
  before_filter :get_variables
  
  protected

    def get_variables
      @current_user = User.find(session[:user_id]) if session[:user_id]
    rescue ActiveRecord::RecordNotFound
      # Clear the session if an invalid user id was found in it
      reset_session
    end
    
    def method_missing(name, *args)
       if match = /authorize_([_a-zA-Z]+)/.match(name.to_s)
        return authorize(match[1])
      else
        super
      end
    end
    
    def authorize_user
      if @current_user
        return true
      else
        flash[:notice] = "You have to be logged in to see this page" unless request.request_uri == root_path
        redirect_to(login_url) and return false
      end
    rescue ActiveRecord::RecordNotFound
      # Couldn't find a valid user, which means the user was deleted
      # therefor, delete the login token and the login user
      reset_login_cookie
      redirect_to(login_url) and return false
    end  
    
    def authorize_admin
      if @current_user
        if @current_user.is_admin?
          return true
        else
          flash[:notice]= "You do not have access to this page"
          redirect_to(dashboard_url) and return false
        end
      else
        flash[:notice] = "You have to be logged in to see this page" unless request.request_uri == root_path
        redirect_to(login_url) and return false
      end
    rescue ActiveRecord::RecordNotFound
      # Couldn't find a valid user, which means the user was deleted
      # therefor, delete the login token and the login user
      reset_login_cookie
      redirect_to(login_url) and return false
    end
  
end
