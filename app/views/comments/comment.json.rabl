attributes :id, :time
attributes :html => :body

node :commenter do |comment|
  # TODO Render user json comment partial
  comment.commenter.comment_json
end
