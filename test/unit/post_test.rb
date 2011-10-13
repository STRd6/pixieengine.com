require 'test_helper'

class MembershipTest < ActiveSupport::TestCase
  should "queue email with Delayed Job on create" do
    assert_difference 'Delayed::Job.count', +1 do
      Factory :post
    end
  end
end
