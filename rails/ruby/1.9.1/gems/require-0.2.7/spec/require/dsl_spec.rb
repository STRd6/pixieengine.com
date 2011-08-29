require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

class Require
  describe Dsl do
    
    it "should store method calls and a value, options array" do
      dsl = Require::Dsl.new
      dsl.call { a 1, 2, 3 }
      dsl.should == [[:a, 1, 2, 3]]
    end
    
    it "should store child blocks" do
      dsl = Require::Dsl.new
      dsl.call do
        a 1 do
          b 2
        end
      end
      dsl.should == [[:a, 1, [[:b, 2]]]]
    end
    
    it "should be able to retrieve a value from the block" do
      dsl = Require::Dsl.new
      dsl.call do
        a 1
        b a
      end
      dsl.should == [[:a, 1], [:b, 1]]
    end
    
    it "should provide a get method" do
      dsl = Require::Dsl.new
      dsl.call do
        a 1 do
          b 2
        end
      end
      dsl.get(:a).should == [:a, 1, [[:b, 2]]]
      dsl.get(:a, 1).should == [:a, 1, [[:b, 2]]]
      dsl.get(:b).should == nil
      dsl.get(:a).get(:b).should == [:b, 2]
      dsl.get(:a).get(:b).get(:c).should == nil
    end
    
    it "should provide an all method" do
      dsl = Require::Dsl.new
      dsl.call do
        a 1
        a 2 do
          b 3
          b 4
        end
      end
      dsl.all(:a).should == [[:a, 1], [:a, 2, [[:b, 3], [:b, 4]]]]
      dsl.all(:a, 1).should == [[:a, 1]]
      dsl.all(:b).should == []
      dsl.all(:a).last.all(:b).should == [[:b, 3], [:b, 4]]
    end
  end
end
