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
    should "be taggable" do
      assert_difference "@sprite.tags.count", +1 do
        @sprite.add_tag("cool")
      end
    end
  end

  context "archiving" do
    should "be archiveable and restoreable" do
      assert_difference "Sprite::Archive.count", +1 do
        assert_difference "Sprite.count", -1 do
          @sprite.destroy
        end
      end

      assert_difference "Sprite::Archive.count", -1 do
        assert_difference "Sprite.count", +1 do
          Sprite.restore_all([ 'id = ?', @sprite.id ])
        end
      end
    end
  end
end
