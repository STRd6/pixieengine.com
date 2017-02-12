class AdminController < ApplicationController
  before_action :check_code, except: [:bounced]
  skip_before_action :verify_authenticity_token

  before_action :verify_mailgun_signature, only: [:bounced]

  def undeliverable
    Email.undeliverable_from_array JSON.parse(request.raw_post)
  end

  def bounced
    Email.mark_undeliverable(params[:recipient])
  end

  private
  def check_code
    if ENV['ADMIN_CODE'] != request.env['HTTP_AUTHORIZATION']
      render nothing: true, status: :unauthorized
    end
  end

  def verify_mailgun_signature
    api_key = ENV["MAILGUN_API_KEY"]
    token = params[:token]
    timestamp = params[:timestamp]
    signature = params[:signature]

    digest = OpenSSL::Digest::SHA256.new
    data = [timestamp, token].join

    signature == OpenSSL::HMAC.hexdigest(digest, api_key, data)

    logger.info "Mailgun signature match: #{signature}"

    return signature
  end
end
