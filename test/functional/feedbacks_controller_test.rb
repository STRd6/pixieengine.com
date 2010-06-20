require 'test_helper'

class FeedbacksControllerTest < ActionController::TestCase
  setup do
    @feedback = Feedback.create :body => "Test"
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create feedback" do
    assert_difference('Feedback.count') do
      post :create, :feedback => @feedback.attributes
    end

    assert_redirected_to thanks_feedbacks_path
  end
end
