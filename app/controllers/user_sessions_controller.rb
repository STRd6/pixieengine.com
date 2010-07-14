class UserSessionsController < ApplicationController
  def new
    @user_session = UserSession.new
  end

  def create
    # Default to remember me
    @user_session = UserSession.new((params[:user_session] || {}).merge(:remember_me => true))
    @user_session.save do |result|
      if result
        new_user = @user_session.user.login_count == 1

        respond_to do |format|
          format.html do
            flash[:notice] = "Login successful!"
            redirect_back_or_default root_path
          end
          format.json { render :json => {:status => "ok"} }
        end
      else
        respond_to do |format|
          format.html { render :action => :new }
          format.json do
            render :json => {
              :status => "error",
              :errors => @user_session.errors.full_messages
            }
          end
        end
      end
    end
  end

  def destroy
    @user_session = UserSession.find
    @user_session.destroy if @user_session
    flash[:notice] = "Successfully logged out."
    redirect_to root_url
  end
end
