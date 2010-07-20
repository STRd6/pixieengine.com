require 'test_helper'

class CollectionTest < ActiveSupport::TestCase
  setup do
    @collection = Factory :collection
  end

  should "belong to a user" do
    assert @collection.user
  end

  should "have many items" do
    assert @collection.items
  end

  should "have a name" do
    assert @collection.name
  end
end
