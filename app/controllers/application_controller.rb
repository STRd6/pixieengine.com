class ApplicationController < ActionController::Base
  include Experimentable
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper
  include Sanitization

  def forem_user
    current_user
  end
  helper_method :forem_user

  helper :all
  protect_from_forgery
  layout 'application'

  helper_method :current_user

  private

  before_filter :track_visits

  after_filter :flash_to_headers

  def track_visits
    landed, returned = session.values_at(:landed, :returned)

    unless landed
      land = true
      track_event('land')
    end

    unless returned
      if current_user && current_user.created_at > 1.day.ago
        returned = true
        track_event('return')
      end
    end

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

  def store_location
    session[:return_to] = request.fullpath
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
  helper_method :per_page

  def page
    params[:page]
  end
  helper_method :page

  def filters
    []
  end

  def filter
    filter = params[:filter] || filters.first
    filter = filter.gsub(' ', '_')

    return filter if filters.include? filter
  end
  helper_method :filter

  def count_view
    object.increment! :views_count
  end
end
