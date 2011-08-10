require 'test_helper'

class ChatsControllerTest < ActionController::TestCase
  setup do
    @user = log_in
    @image_text = "<img src=\"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAqElEQVRYR+2WwQ6AMAhDt///aM0OJMsCFMiUS73q2kcBdY7mazb7DwIwgVsJPGCYTR8EgIR3X0tLNNT7HoB7MLm+S6sEgBKKcqQBrAN7SzS4s2XyTAlgVXea/AawzDXqdoBIz7XhTbfASqAC8MkamhUphGUALwU0C8IB3yVoz6GA05PQWQQgKWgr6c1DyDwjmo08rB1JYK8UfZyyevwlYwJMgAkwgf4EXnGqJiHjLmjqAAAAAElFTkSuQmCC\">"
  end

  should "create a new Chat" do
    assert_difference 'Chat.count', +1 do
      post :create, :body => 'This is a chat msg'
    end
  end

  should "preserve images" do
    post :create, :body => @image_text

    assert Chat.last.text.length == @image_text.length
  end
end
