require 'test_helper'

class SpritesControllerTest < ActionController::TestCase
  setup do
    @sprite = Factory :sprite
  end

  should "not be able to edit another's sprite" do
    get :edit, :id => @sprite.id
    assert_response :redirect
  end

  should "be able to view a sprite" do
    get :show, :id => @sprite.id
    assert_response :success
  end

  context "a logged in user" do
    setup do
      @user = log_in
      @sprite = Factory :sprite, :user => @user
    end

    should "be able to edit own sprite" do
      get :edit, :id => @sprite.id
      assert_response :success
    end

    should "be able to delete own sprite" do
      post :destroy, :id => @sprite.id
      assert_equal 'Sprite has been deleted.', flash[:notice]
      assert_response :redirect
    end

    should "be able to save a sprite from the pixel editor" do
      post :create,
        sprite: {
          width: "4",
          height: "4",
          file_base64_encoded: "iVBORw0KGgoAAAANSUhEUgAAAAQAAAAECAYAAACp8Z5+AAAAE0lEQVQIW2N8zc73nwEJMJIuAAA/1wgBxJxmOgAAAABJRU5ErkJggg=="
        }
    end
  end
end
