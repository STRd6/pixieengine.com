class ApplicationController < ActionController::Base
  helper :all
  protect_from_forgery
  layout 'application'

  helper_method :current_user

  private

  before_filter :set_abingo_identity, :track_visits

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

  def track_visits
    Visit.track(current_user, controller_name, action_name, request.session_options[:id])
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
      redirect_to new_user_session_url, :notice => "You must be logged in to access this page"
      return false
    end
  end

  def require_no_user
    if current_user
      store_location
      redirect_to root_url, :notice => "You must be logged out to access this page"
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
    if specified_object
      (current_user == specified_object.user) && current_user
    else
      (current_user == object.user) && current_user
    end
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

  def store_location
    session[:return_to] = request.request_uri
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def facebook?
    !!params[:fb_sig]
  end
  helper_method :facebook?

  def context
    nil
  end
  helper_method :context

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

  def hide_feedback
    @hide_feedback = true
  end

  def hide_dock
    @hide_dock = true
  end

  def per_page
    40
  end

  def filters
    []
  end

  def filter
    if params[:filter] && filters.include?(params[:filter])
      params[:filter]
    else
      filters.first
    end
  end
end
