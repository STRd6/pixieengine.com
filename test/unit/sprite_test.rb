require 'test_helper'

class SpriteTest < ActiveSupport::TestCase
  setup do
    @sprite = Factory :sprite
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

  context "tagging" do
    setup do
      @test_tag = "test"
      @sprite.update_attribute(:tag_list, @test_tag)
    end

    should "be taggable" do
      assert_difference "@sprite.tags.count", +1 do
        @sprite.add_tag("cool")
      end
    end

    should "be able to remove a tag" do
      assert_difference "@sprite.tags.count", -1 do
        @sprite.remove_tag(@test_tag)
      end
    end
  end
end
