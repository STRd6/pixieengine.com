class AdminController < ApplicationController
  before_action :check_code
  skip_before_action :verify_authenticity_token

  def undeliverable
    Email.undeliverable_from_array JSON.parse(request.raw_post)
  end

  private
  def check_code
    if ENV['ADMIN_CODE'] != request.env['HTTP_AUTHORIZATION']
      render nothing: true, status: :unauthorized
    end
  end
end
