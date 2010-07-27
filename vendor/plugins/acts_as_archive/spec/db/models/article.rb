class Article < ActiveRecord::Base
  acts_as_archive :indexes => [ :id, [:subject_id, :subject_type], :deleted_at ]
  belongs_to :subject, :polymorphic => true
end
