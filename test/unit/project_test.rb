require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  context "project with remote origin" do
    setup do
      @project = Factory :project, :remote_origin => "git@github.com:STRd6/cardprinter.git"
    end

    should "have a url" do
      assert @project.url == "https://github.com/STRd6/cardprinter"
    end
  end
end
