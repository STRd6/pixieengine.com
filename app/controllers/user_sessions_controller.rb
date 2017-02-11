class UserSessionsController < ApplicationController
  def new
  end

  def create
    if params[:user_session][:login] == "yes"
      # Default to remember me
      @user_session = UserSession.new((params[:user_session] || {}).merge(:remember_me => true))
      @user_session.save do |result|
        if result
          new_user = @user_session.user.login_count == 1

          respond_to do |format|
            format.html do
              save_sprites_to_user(@user_session.user)

              flash[:notice] = "Login successful!"
              redirect_back_or_default root_path
            end
            format.json { render :json => {:status => "ok"} }
          end
        else
          respond_to do |format|
            format.html { render "new" }
            format.json do
              render :json => {
                :status => "error",
                :errors => @user_session.errors.full_messages
              }
            end
          end
        end
      end
    else
      session[:email] = params[:user_session][:email]

      redirect_to new_user_path
    end
  end

  def oauth
    provider = params[:provider]
    token = auth_hash["credentials"]["token"]

    current_user.update_oauth(provider, token)

    # render :text => "<pre>"+auth_hash.to_yaml+"</pre>"

    flash[:notice] = "#{provider} Authorized"
    redirect_to root_path
  end

  def destroy
    @user_session = UserSession.find
    @user_session.destroy if @user_session

    redirect_to root_url, :notice => "Successfully logged out."
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end
