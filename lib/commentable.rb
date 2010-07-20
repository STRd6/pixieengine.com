module Commentable
  def self.included(model)
    model.class_eval do
      has_many :comments, :as => :commentable, :order => "id DESC"
    end
  end
end
