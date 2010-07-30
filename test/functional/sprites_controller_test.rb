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
  end
end
