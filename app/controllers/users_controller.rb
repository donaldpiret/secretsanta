class UsersController < ApplicationController
  
  before_filter :authorize_admin, :only => [:new, :create, :destroy]
  before_filter :can_only_edit_self, :only => [:edit, :update]
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    @user.save!
    flash[:notice] = "User created"
    redirect_to dashboard_url
  rescue ActiveRecord::RecordInvalid
    render :action => 'new'
  end
  
  def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
    @user.update_attributes!(params[:user])
  rescue ActiveRecord::RecordInvalid
    render :action => 'edit'
  end
  
  def destroy
    @user = User.find(params[:id])
    if @user.destroy
      flash[:notice] = "User deleted"
      redirect_to dashboard_url
    else
      flash[:notice] = "Could not delete user"
      redirect_to dashboard_url
    end
  end
  
private

  ###
  # Callbacks
  
  def can_only_edit_self
    unless @current_user.is_admin? || @current_user.id == params[:id]
      flash[:notice] = "You are not allowed to edit somebody else"
      redirect_to dashboard_url and return false
    end
  end
  
end
