class SessionsController < ApplicationController

  skip_before_action :verify_authenticity_token, :only => [:googlecreate]

  def new
    @user = User.new
    render :login
  end

  #login action
  def create
    #look up the user by email and set the variable
    @user = User.find_by(email: params[:email])
    
    # does the user exist(not nil) and is the password correct? if so set session id
    if @user && @user.authenticate(params[:password])
      session[:user_id] = @user.id
      redirect_to user_path(@user)
    
      # otherwise go back to login
    else
      @error = true
      render :login
    end
  end

  def googlecreate
    # we trust the user at this point because google said yea this guy is the guy
    # this is for creating an account when there is no local account
    if !User.find_by(uid: auth['uid']) && !User.find_by(email: auth['info']['email'])
      @user = User.new
      @user.first_name = auth['info']['first_name']
      @user.last_name = auth['info']['last_name']
      @user.email = auth['info']['email']
      @user.uid = auth['uid']
      @user.password = SecureRandom.hex
      @user.save
      session[:user_id] = @user.id  #actually log em in

      redirect_to root_path

      # if they have a local account already then we try to match to that account and connect them
    elsif !User.find_by(uid: auth['uid']) && User.find_by(email: auth['info']['email'])
      @user = User.find_by(email: auth['info']['email'])
      @user.uid = auth['uid']
      #could have comfirm passw but for now ill say if google trusts em so will i
      @user.save
      session[:user_id] = @user.id
      redirect_to root_path
    else
      # otherwise they have an account via google already so we log em in
      @user = User.find_by(uid: auth['uid'])
      session[:user_id] = @user.id  
      redirect_to root_path 
    end
  
  end

  def home
  end

  #logout route
  def destroy
    session.clear
    redirect_to '/'
  end

  private

  def auth
    request.env['omniauth.auth']
  end

end

