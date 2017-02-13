class HomeController < ApplicationController
  before_action :hide_feedback

  def sitemap
    @sprite_pages_count = Sprite.count / Sprite.per_page
    @users = User.select("id, display_name, updated_at")
    @sprites = Sprite.select("id, title, updated_at").limit(1_000).order("id DESC")

    render layout: false
  end

  def survey
  end

  def unsubscribe
    verifier = ActiveSupport::MessageVerifier.new(Rails.application.secrets.secret_key_base)
    address = verifier.verify(params[:signature])
    Rails.logger.info "Verified: #{address}"

    @address = address
    Email.mark_unsubscribed(address)
  end

  private
  def hide_feedback
    @hide_feedback = true
  end

  helper_method :w3c_date
  def w3c_date(date)
    date.utc.strftime("%Y-%m-%dT%H:%M:%S+00:00")
  end
end
