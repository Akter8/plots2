class UserSessionsController < ApplicationController

  def new
    @title = "Log in"
  end

  def create
    openid = params[:user_session][:openid_identifier] if params[:user_session] && params[:user_session][:openid_identifier] != ""
    params[:user_session][:openid_identifier] = "http://publiclaboratory.org/people/"+openid+"/identity" if params[:user_session] && params[:user_session][:openid_identifier] != ""

    if params[:user_session].nil? || !User.find_by_username(openid).nil? || !User.find_by_username(params[:user_session][:username]).nil?
      @user_session = UserSession.new(params[:user_session])
      @user_session.save do |result|
        if result
          flash[:notice] = "Successfully logged in."
          if session[:return_to] # for openid login, redirects back to openid auth process
            redirect_to session[:return_to]
          elsif params[:return_to]
            redirect_to params[:return_to]
          else
            redirect_to "/dashboard"
          end
        else
          render :action => 'new'
        end
      end
    else
      if !DrupalUsers.find_by_name(openid).nil? || !DrupalUsers.find_by_name(params[:user_session][:username]).nil? 
        # this is a user from the old site who hasn't registered on the new site
        redirect_to :controller => :users, :action => :create, :user => {:openid_identifier => openid}
      else
        flash[:warning] = "It looks like you're new here! Sign up below to join."
        redirect_to "/signup"
      end
    end
  end

  def destroy
    @user_session = UserSession.find
    @user_session.destroy
    flash[:notice] = "Successfully logged out."
    redirect_to root_url
  end

end
