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

  context "comment emails"
    should "sent to someone who receives a comment" do
      user = create :user,
        site_notifications: true
      sprite = create :sprite,
        user: user
      commenter = create :user

      # Create comment and verify one email was sent
      assert_difference 'ActionMailer::Base.deliveries.size', 1 do
        create :comment,
          commenter: commenter,
          commentee: user,
          commentable: sprite
      end
    end

    should "not send to someone who has opted out of receiving email" do
      user = create :user,
        site_notifications: false
      sprite = create :sprite,
        user: user
      commenter = create :user

      # Create comment and verify no email was sent
      assert_difference 'ActionMailer::Base.deliveries.size', 0 do
        create :comment,
          commenter: commenter,
          commentee: user,
          commentable: sprite
      end

    end

    should "not send to someone who's email is undeliverable" do
      user = create :user
      undeliverable = create :undeliverable_email,
        email: user.email
      sprite = create :sprite,
        user: user
      commenter = create :user

      # Create comment and verify that no email was sent
      assert_difference 'ActionMailer::Base.deliveries.size', 0 do
        create :comment,
          commenter: commenter,
          commentee: user,
          commentable: sprite
      end

    end
end
