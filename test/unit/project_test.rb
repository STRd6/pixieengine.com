require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  context "project with remote origin" do
    setup do
      @project = Factory :project, :remote_origin => "git@github.com:STRd6/cardprinter.git"
    end

    should "be able to commit and push changes" do
      @project.git_push
    end
  end
end
