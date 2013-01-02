require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    @user = Factory :user
  end

  should "send welcome email on create" do
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      Factory :user
    end
  end

  should "validate display name like a mofo" do
    assert @user.valid?

    @user.display_name = "..."

    assert @user.invalid?
  end

  context "collections" do
    setup do
      @collection_name = "favorites"
      @user.add_to_collection(Factory(:sprite), @collection_name)
    end

    should "be able to add an item to a collection" do
      item = Factory :sprite
      @user.add_to_collection(item, @collection_name)

      assert @user.collections.find_by_name(@collection_name).include?(item)
    end

    should "be able to remove an item from a collection" do
      item = @user.collections.find_by_name(@collection_name).items.first

      @user.remove_from_collection(item, @collection_name)

      assert !@user.collections.find_by_name(@collection_name).include?(item)
    end
  end

  context "oauth" do
    should "be able to update oauth token" do
      assert_difference "@user.oauth_tokens.size", +1 do
        @user.update_oauth("test", "test_token")
      end
    end
  end

  context "plugins" do
    setup do
      @installed_plugin = Factory :plugin

      @user.install_plugin(@installed_plugin)
    end

    should "be able to install a plugin" do
      assert_difference "@user.installed_plugins.size", +1 do
        @user.install_plugin(Factory(:plugin))
      end
    end

    should "be able to uninstall a plugin" do
      assert_difference "@user.installed_plugins.size", -1 do
        @user.uninstall_plugin(@installed_plugin)
      end
    end
  end
end
