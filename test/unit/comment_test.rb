require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  should "have working as_json method even if the commentable has been deleted" do
    comment = Factory :comment
    comment.stubs(:commentable).returns(nil)

    assert_nothing_raised do
      comment.as_json
    end
  end
end
