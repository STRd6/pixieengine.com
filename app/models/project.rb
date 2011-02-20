class Project < ActiveRecord::Base
  belongs_to :user
  
  after_create :clone_repo

  BRANCH_NAME = "pixie"
  
  def base_path
    Rails.root.join 'public', 'production', 'projects'
  end

  def path
    base_path.join(id.to_s).to_s
  end

  def clone_repo
    if remote_origin
      system "git", "clone", remote_origin, path
      system "cd #{path} && git checkout -b #{BRANCH_NAME}"
    end
  end

  def git_push
    system "cd #{path} && git push origin #{BRANCH_NAME}"
  end
end
