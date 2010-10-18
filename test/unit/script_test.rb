require 'test_helper'

class ScriptTest < ActiveSupport::TestCase
  setup do
    @script = Factory :script
  end

  context "User Access:" do
    context "members" do
      setup do
        @script_member = Factory :user
        ScriptMember.create(:script => @script, :user => @script_member)
      end

      should "have access to script" do
        assert @script.has_access?(@script_member)
      end
    end

    context "non members" do
      setup do
        @non_member = Factory :user
      end

      should "not have access to script" do
        assert !@script.has_access?(@non_member)
      end
    end
  end
end
