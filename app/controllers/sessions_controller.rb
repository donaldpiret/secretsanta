class SessionsController < ApplicationController
  
  before_filter :authorize_user, :except => [:new, :create]
  
  def new
    (redirect_to root_url and return) if @current_user
  end
  
  def create
    @username, @password = params[:session][:username], params[:session][:password]
    @current_user = User.authenticate(@username, @password)
    if @current_user
      @current_user.login!(session)
      if session[:return_to]
        correct_login(session[:return_to]) and return
      else
        correct_login(dashboard_url) and return
      end
    else
      incorrect_login("Invalid username/password")
    end
  end
  
  def destroy
    @current_user.logout!(session) if @current_user
    flash[:notice] = "Logged out"
    redirect_to login_url
  end
  
private

  # Helper method to redirect correctly using the respond_to
  def correct_login(url)
    respond_to do |accepts|
      accepts.html { redirect_to url }
      accepts.js { redirect_to url }
    end
  end

  def incorrect_login(error)
    reset_session
    respond_to do |accepts|
      accepts.html {
        flash[:error] = error
        redirect_to login_url
      }
      accepts.js {
        flash[:error] = error
        redirect_to login_url
      }
    end
  end
  
end
