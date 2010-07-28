require 'test_helper'

class LibraryTest < ActiveSupport::TestCase
  context "library" do
    setup do
      @library = Factory :library
    end

    should "be able to add a script" do
      assert_difference "@library.scripts.count", +1 do
        @library.add_script(Factory(:script))
      end
    end

    should "be able to add a component library" do
      assert_difference "@library.component_libraries.count", +1 do
        @library.add_component_library(Factory(:library))
      end
    end
  end
end
