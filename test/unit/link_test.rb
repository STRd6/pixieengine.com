require 'test_helper'

class LinkTest < ActiveSupport::TestCase
  context "link" do
    setup do
      @link = Factory :link
    end

    should "have a token" do
      assert @link.token
    end

    should "have a target" do
      assert @link.target
    end
  end
end
