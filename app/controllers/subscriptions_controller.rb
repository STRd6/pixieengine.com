class SubscriptionsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => :changed
  before_filter :require_user, :only => [:subscribe]

  def subscribe
  end

  def changed
    subscriber_ids = params[:subscriber_ids].split(',')

    User.update_paying(subscriber_ids)

    head(:ok)
  end
end
