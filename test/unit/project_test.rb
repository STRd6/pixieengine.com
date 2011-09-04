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

  context "archiving" do
    setup do
      @project = Factory :project
    end

    should "be archiveable and restoreable" do
      assert_difference "Project::Archive.count", +1 do
        assert_difference "Project.count", -1 do
          @project.destroy
        end
      end

      assert_difference "Project::Archive.count", -1 do
        assert_difference "Project.count", +1 do
          Project.restore_all([ 'id = ?', @project.id ])
        end
      end
    end
  end

  context "memberships" do
    setup do
      @project = Factory :project

      @member = Factory :user
      @non_member = Factory :user

      Membership.create :group => @project, :user => @member
    end

    should "know members" do
      assert @project.has_access?(@member)
      assert !@project.has_access?(@non_member)
    end
  end
end
