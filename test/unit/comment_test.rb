require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  should "queue email with Delayed Job on create" do
    assert_difference 'Delayed::Job.count', +1 do
      Factory :comment
    end
  end

  should "have working as_json method even if the commentable has been deleted" do
    comment = Factory :comment
    comment.stubs(:commentable).returns(nil)

    assert_nothing_raised do
      comment.as_json
    end
  end
end
