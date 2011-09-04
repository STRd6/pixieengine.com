require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

class Require
  describe Gemspec do
    
    it "should generate a valid gemspec instance" do
      Require.stub!(:root).and_return(SPEC + "/fixture")
      Require.reset do
        gem :rspec, '=1.3.0'
      
        gemspec do
          author 'Winton Welsh'
          dependencies do
            gem :rspec
          end
          email 'mail@wintoni.us'
          name 'require'
          homepage "http://github.com/winton/#{name}"
          summary "summary"
          version '0.1.0'
        end
      end
      
      FileUtils.mkdir_p(File.expand_path("#{File.dirname(__FILE__)}/../fixture/ignore_me"))
      
      s = Require.gemspec
      s.authors.should == [ "Winton Welsh" ]
      s.date.should == Time.local(Time.now.year, Time.now.mon, Time.now.mday, 0)
      s.default_executable.should == "bin"
      s.dependencies.should == [Gem::Dependency.new("rspec", Gem::Requirement.new(["= 1.3.0"]), :runtime)]
      s.email.should == 'mail@wintoni.us'
      s.executables.should == ["bin"]
      s.extra_rdoc_files.should == ["README.markdown"]
      s.files.should == ["bin", "bin/bin", "lib", "lib/lib.rb", "README.markdown"]
      s.homepage.should == "http://github.com/winton/require"
      s.name.should == "require"
      s.require_paths.should == ["lib"]
      s.summary.should == 'summary'
    end
  end
end
