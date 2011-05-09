# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
PixieStrd6Com::Application.initialize!

WillPaginate::ViewHelpers.pagination_options[:previous_label] = '« Previous'
WillPaginate::ViewHelpers.pagination_options[:next_label] = 'Next »'
