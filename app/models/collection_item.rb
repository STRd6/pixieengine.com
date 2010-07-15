class CollectionItem < ActiveRecord::Base
  belongs_to :collection
  belongs_to :item, :polymorphic => true
end
