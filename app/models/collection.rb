class Collection < ActiveRecord::Base
  include Commentable

  belongs_to :user
  has_many :collection_items
  has_many :sprites, :through => :collection_items, :source => :item, :source_type => 'Sprite'

  def title
    name
  end

  def add(item)
    collection_items.create(:item => item)
  end

  def remove(item)
    collection_items.find_by_item(item).each(&:destroy)
  end

  def items
    collection_items.map(&:item)
  end

  def sprites
    collection_items.all(:conditions => "item_type = 'Sprite'").map(&:item)
  end

  def include?(item)
    items.include?(item)
  end
end
