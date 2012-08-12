require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  context "vanity projects" do
    setup do
      @project = Factory :project
    end

    should "be findable via a numberic id or a title" do
      project = Project.find(@project.id)

      assert_not_nil project

      project = Project.find(@project.title)

      assert_not_nil project
    end
  end

  context "project with remote origin" do
    setup do
      @project = Factory :project, :remote_origin => "git@github.com:STRd6/cardprinter.git"
    end

    should "have a url" do
      assert @project.url == "https://github.com/STRd6/cardprinter"
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
