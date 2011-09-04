require "#{File.dirname(__FILE__)}/spec_helper"

describe Require do
  
  before(:all) do
    @fixture = File.dirname(__FILE__) + '/fixture'
    Require.reset do
      gem :rake, '=0.8.7'
      gem(:rspec, '=1.3.0') { require 'spec' }
      
      rakefile do
        require 'test'
        load_path File.dirname(__FILE__) + '/fixture'
        gem(:rake) { require 'rake/gempackagetask' }
        gem(:rspec, '>1.2.9') { require 'spec/rake/spectask' }
      end
    end
  end
  
  it "should provide a load_path! method" do
    Require.send :load_path!, @fixture
    $:.include?(@fixture).should == true
  end
  
  it "should provide a require_gem! method" do
    Kernel.should_receive(:gem).with('rspec', '=1.3.0')
    Require.should_receive(:require!).with('spec')
    Require.send :require_gem!, :rspec
  end
  
  it "should provide a require_gem! method with optional overwrite methods" do
    Kernel.should_receive(:gem).with('rspec', '>1.2.9')
    Require.should_receive(:require!).with('spec/rake/spectask')
    dsl = Require.get(:rakefile).get(:gem, :rspec).last
    Require.send :require_gem!, :rspec, '>1.2.9', dsl
  end
  
  it "should provide a require! method" do
    Kernel.should_receive(:require).with('spec')
    Require.send :require!, 'spec'
  end
  
  it "should require gems through the bang shortcut" do
    Require.should_receive(:require_gem!).with(:rspec)
    Require.rspec!
  end
  
  it "should require profiles through the bang shortcut" do
    Require.should_receive(:require!).with('test')
    Require.should_receive(:require_gem!).with(:rake, nil, [[:require, "rake/gempackagetask"]])
    Require.should_receive(:require_gem!).with(:rspec, '>1.2.9', [[:require, "spec/rake/spectask"]])
    Require.should_receive(:load_path!).with(@fixture)
    Require.rakefile!
  end
end
