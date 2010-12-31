# Be sure to restart your server when you modify this file.

PixieStrd6Com::Application.config.session_store :cookie_store, :key => '_pixie_strd6_com_session'

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# Rails.application.config.session_store :active_record_store

PixieStrd6Com::Application.config.middleware.insert_before(
  ActionDispatch::Session::CookieStore,
  FlashSessionCookieMiddleware,
  Rails.application.config.session_options[:key]
)
