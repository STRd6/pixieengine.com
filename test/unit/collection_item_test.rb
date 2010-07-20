require 'test_helper'

class CollectionItemTest < ActiveSupport::TestCase
  setup do
    @collection_item = Factory :collection_item
  end

  should "belong to a collection" do
    assert @collection_item.collection
  end
end
