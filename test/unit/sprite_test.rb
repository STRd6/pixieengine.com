require 'test_helper'

class SpriteTest < ActiveSupport::TestCase
  context "a sprite" do
    setup do
      @sprite = Factory :sprite
    end

    # Replace this with your real tests.
    should "exist" do
      assert @sprite
    end
  end

  context "derivation" do
    setup do
      @parent = Factory :sprite
      @sprite = Factory :sprite, :parent => @parent
    end

    should "have a parent" do
      # Reload from DB
      @sprite = Sprite.find(@sprite)

      assert_equal @parent, @sprite.parent
    end
  end
end
