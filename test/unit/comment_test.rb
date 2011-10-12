require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  should "queue email with Delayed Job on create" do
    assert_difference 'Delayed::Job.count', +1 do
      Factory :comment
    end
  end
end
