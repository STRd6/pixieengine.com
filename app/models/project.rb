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

  def git_commit
    #TODO: Maybe scope to specific files
    system "cd #{path} && git add ."

    #TODO: Shell escape user display name and add to commit message
    system "cd #{path} && git commit -m 'pixie'"
  end

  def file_info
    file_node_data path
  end

  def file_node_data(file_path)
    filename = File.basename file_path

    if File.directory? file_path
      {
        :name => filename,
        :ext => "directory",
        :files => Dir.new(file_path).map do |filename|
          next if filename[0...1] == "."

          file_node_data(File.join(file_path, filename))
        end.compact
      }
    elsif File.file? file_path
      {
        :name => filename,
        :ext => File.extname(filename)[1..-1],
        :size => File.size(file_path),
        :path => file_path,
      }
    end
  end
end
