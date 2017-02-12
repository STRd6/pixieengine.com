class Email < ActiveRecord::Base
  def self.undeliverable_from_array(data)
    data.each do |address|
      self.mark_undeliverable(address)
    end
  end

  def self.mark_undeliverable(address)
    Email.find_or_create_by(email: address) do |email|
      email.undeliverable = true
    end
  end
end
