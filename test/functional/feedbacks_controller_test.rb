require 'test_helper'

class FeedbacksControllerTest < ActionController::TestCase
  setup do
    @feedback = Feedback.create :body => "Test"
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:feedbacks)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create feedback" do
    assert_difference('Feedback.count') do
      post :create, :feedback => @feedback.attributes
    end

    assert_redirected_to feedback_path(assigns(:feedback))
  end

  test "should show feedback" do
    get :show, :id => @feedback.to_param
    assert_response :success
  end
end
