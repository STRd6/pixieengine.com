class Subscriber < ActiveResource::Base
  self.site = "https://spreedly.com/api/v4/STRd6-test"
  self.user =  APP_CONFIG[:spreedly_token]
end
