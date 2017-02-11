class CollectionItem < ActiveRecord::Base
  belongs_to :collection
  belongs_to :item, :polymorphic => true, :counter_cache => :favorites_count

  validates :item_id, uniqueness: {scope: [:collection, :item_type]}

  scope :find_by_item, lambda { |item|
    where("collection_items.item_id = ? AND collection_items.item_type = ?", item.id, item.class.to_s)
  }

  def self.dedupe
    grouped = all.group_by {|item| [item.item_id, item.collection_id, item.item_type]}

    grouped.values.each do |group|
      group.shift

      group.each(&:destroy)
    end
  end
end
