require 'test_helper'

class SpritesControllerTest < ActionController::TestCase
  setup do
    @sprite = create :sprite
  end

  should "not be able to edit another's sprite" do
    get :edit, params: {
      id: @sprite.id
    }
    assert_response :redirect
  end

  should "be able to view a sprite" do
    get :show, params: {
      id: @sprite.id
    }
    assert_response :success
  end

  should "be able to get sprites list as json" do
    get :index, :format => :json
    body = JSON.parse(response.body)

    assert_equal body[0]["id"], @sprite.id
  end

  context "a logged in user" do
    setup do
      @user = log_in
      @sprite = create :sprite, :user => @user
    end

    should "be able to view the edit page of own sprite" do
      get :edit, params: {
        id: @sprite.id
      }
      assert_response :success
    end

    should "be able to delete own sprite" do
      post :destroy, params: {
        id: @sprite.id
      }
      assert_response :redirect
      assert_equal 'Sprite has been deleted.', flash[:notice]
    end

    should "be able to edit own sprite" do
      post :update, params: {
        id: @sprite.id, 
        sprite: { 
          title: "duder"
        }
      }
      assert_response :redirect

      assert_equal "duder", assigns(:sprite).title
    end

    should "be able to save a sprite from the pixel editor" do
      post :create, params: {
        sprite: {
          width: "4",
          height: "4",
          file_base64_encoded: "iVBORw0KGgoAAAANSUhEUgAAAAQAAAAECAYAAACp8Z5+AAAAE0lEQVQIW2N8zc73nwEJMJIuAAA/1wgBxJxmOgAAAABJRU5ErkJggg=="
        }
      }

      assert_redirected_to sprite_path(assigns(:sprite))
    end

    should "be able to load a sprite in the pixel editor" do
      get :load, params: {
        id: @sprite.id
      }
      assert_response :success
    end
  end
end
