require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  should "have working as_json method even if the commentable has been deleted" do
    comment = create :comment
    comment.stubs(:commentable).returns(nil)

    assert_nothing_raised do
      comment.as_json
    end
  end

  context "without replies" do
    setup do
      @comment = create :comment
    end

    should "not be in reply to anything by default" do
      assert_nil @comment.in_reply_to
    end

    should "not have any replies by default" do
      assert_equal @comment.replies.size, 0
    end
  end

  context "with replies" do
    setup do
      @comment = create :comment

      @reply = create :comment, :in_reply_to => @comment
    end

    should "have replies" do
      assert_equal @comment.replies.first, @reply
    end

    should "know what it is in reply to" do
      assert_equal @reply.in_reply_to, @comment
    end

    should "have the same root" do
      assert_equal @comment.root, @reply.root
    end
  end

  context "root" do
    setup do
      @comment = create :comment
    end

    should "be its own root" do
      assert_equal @comment, @comment.root
    end
  end
end
