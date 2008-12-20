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
    flash[:notice] = "User updated"
    redirect_to dashboard_url
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
  
  def pick
    raise Exception, "You have already picked" and return false if @current_user.has_picked?
    User.transaction do 
      possible_picks = User.find(:all, :conditions => ["users.id <> ? AND users.has_been_picked = ?", @current_user.id, false])
      if possible_picks.empty?
        if User.all.size == 1
          flash[:notice] = "You can only pick yourself..."
        else
          flash[:notice] = "There is only yourself left to pick.! Bad luck, the application has been reset and everybody has been notified. Please try picking again."
          bad_pick(@current_user)
        end
        redirect_to dashboard_url
      else
        # Possible to pick
        selected_pick = possible_picks[rand(possible_picks.size)]
        @current_user.pick!(selected_pick)
        flash[:notice] = "Good pick, lucky you!! An email has been sent to your email address with a reminder of your pick."
        flash[:pick_name] = selected_pick.name
        # If this was the last pick
        if User.find(:all, :conditions => {:has_picked => false}).empty?
          Notifications.deliver_goodround(@current_user)
        end
        redirect_to dashboard_url
      end
    end
  end
  
protected

  ###
  # Special Methods

  def bad_pick(last_user)
    Notifications.deliver_badround(last_user)
    User.clear_picks!
  end
  
private

  ###
  # Callbacks
  
  def can_only_edit_self
    unless @current_user.is_admin? || @current_user.id == params[:id].to_i
      flash[:notice] = "You are not allowed to edit somebody else"
      redirect_to dashboard_url and return false
    end
  end
  

  
end
