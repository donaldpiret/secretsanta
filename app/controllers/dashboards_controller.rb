class DashboardsController < ApplicationController
  
  before_filter :authorize_user
  
  def show
    @users = User.all if @current_user.is_admin?
  end
end
