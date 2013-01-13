node(:per_page) { @models.per_page }
node(:page) { page }
node(:total) { @models.total_pages }

child @models.map(&:commentable) => :models do

  node do |commentable|
    partial "comments/#{commentable.class.name.underscore}", :object => commentable
  end

    # :commentable => commentable_json,

  child :recent_comments => :comments do
    extends "comments/comment"
  end

end
