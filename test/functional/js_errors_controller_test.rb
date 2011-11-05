require 'test_helper'

class JsErrorsControllerTest < ActionController::TestCase
  should "create a new JsError" do
    assert_difference 'JsError.count', +1 do
      post :create, :js_error => {
        :message => "Test",
        :line_number => "1",
        :url => "/test",
        :session_id => "TEST_SESSION_ID",
      }
    end
  end
end
