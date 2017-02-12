class Email < ActiveRecord::Base
  def self.undeliverable_from_array(data)
    data.each do |address|
      Rails.logger.info "#{address} is undeliverable"
      Email.find_or_create_by(email: address) do |email|
        email.undeliverable = true
      end
    end
  end
end
