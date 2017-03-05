class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include ActionController::MimeResponds

  def redirect_back_or_root
    redirect_back fallback_location: root_path
  end

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
  end
  helper_method :current_user

  def require_user
    unless current_user
      store_location
      redirect_to sign_in_path, :notice => "You must log in to access this page"
      return false
    end
  end

  def require_no_user
    if current_user
      store_location
      redirect_to root_url, :notice => "You must log out to access this page"
    end
  end

  def require_owner
    unless owner?
      redirect_to root_url, :notice => "You can only edit your own items!"
    end
  end

  def require_access
    unless has_access?
      redirect_to root_url, :notice => "You do not have access to do this!"
    end
  end

  def require_admin
    unless admin?
      redirect_to root_url, :notice => "Admin required"
    end
  end

  def require_owner_or_admin
    unless owner? || admin?
      redirect_to root_url, :notice => "You can only edit your own items!"
    end
  end

  def owner?(specified_object = nil)
    owned_object = specified_object || object

    return current_user && current_user == owned_object.user
  end
  helper_method :owner?

  def has_access?
    owner? || object.has_access?(current_user)
  end
  helper_method :has_access?

  def admin?
    current_user && current_user.admin?
  end
  helper_method :admin?

  def owner_or_admin?(specified_object = nil)
    owner?(specified_object) || admin?
  end
  helper_method :owner_or_admin?

  def track_event(*args)
    # TODO: !
  end

  def save_sprites_to_user(user)
    (session[:saved_sprites] || {}).each do |sprite_id, broadcast|
      if sprite_id
        sprite = Sprite.find(sprite_id)
        sprite.update_attribute(:user, user)
      end
    end

    session[:saved_sprites] = nil
  end

  def store_location
    if request.method == "GET"
      session[:return_to] = request.fullpath
    else
      session[:return_to]= request.referer
    end
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
end
