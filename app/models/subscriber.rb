class Subscriber < ActiveResource::Base
  SITE = Rails.env.production? ? "pixie" : "STRd6-test"

  self.format = :xml
  self.site = "https://spreedly.com/api/v4/#{SITE}"
  self.user =  APP_CONFIG[:spreedly_token]
end
