class ApplicationController < ActionController::Base
  helper :all
  protect_from_forgery
  layout 'application'

  helper_method :current_user

  private

  before_filter :set_abingo_identity

  after_filter :flash_to_headers

  def set_abingo_identity
    if request.user_agent =~ /\b(Baidu|Gigabot|Googlebot|libwww-perl|lwp-trivial|msnbot|SiteUptime|Slurp|WordPress|ZIBB|ZyBorg)\b/i
      Abingo.identity = "robot"
    elsif current_user
      Abingo.identity = current_user.id
    else
      session[:abingo_identity] ||= rand(10 ** 10)
      Abingo.identity = session[:abingo_identity]
    end
  end

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
  end

  def require_user
    unless current_user
      store_location
      flash[:notice] = "You must be logged in to access this page"
      redirect_to new_user_session_url
      return false
    end
  end

  def require_no_user
    if current_user
      store_location
      flash[:notice] = "You must be logged out to access this page"
      redirect_to root_url
    end
  end

  def require_owner
    unless owner?
      flash[:notice] = "You can only edit your own dealies!"
      redirect_to root_url
    end
  end

  def require_admin
    unless admin?
      flash[:notice] = "Admin required"
      redirect_to root_url
    end
  end

  def require_owner_or_admin
    unless owner? || admin?
      flash[:notice] = "You can only edit your own dealies!"
      redirect_to root_url
    end
  end

  def owner?
    (current_user == object.user) && current_user
  end
  helper_method :owner?

  def admin?
    current_user && current_user.admin?
  end
  helper_method :admin?

  def owner_or_admin?
    owner? || admin?
  end
  helper_method :owner_or_admin?

  def store_location
    session[:return_to] = request.request_uri
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def flash_to_headers
    return unless request.xhr?

    #TODO Use header magic to communicate flash messages to jQuery
    # http://stackoverflow.com/questions/366311/how-do-you-handle-rails-flash-with-ajax-requests

    flash.discard
  end

  def save_sprites_to_user(user)
    (session[:saved_sprites] || {}).each do |sprite_id, broadcast|
      sprite = Sprite.find(sprite_id)
      sprite.update_attribute(:user, user)
      if broadcast == "1"
        sprite.broadcast_link
      end
    end

    session[:saved_sprites] = nil
  end
end
