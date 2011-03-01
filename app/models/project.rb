class Project < ActiveRecord::Base
  belongs_to :user
  
  after_create :clone_repo

  after_save :import_files

  attr_accessor :import_zip

  scope :for_user, lambda {|user|
    where(:user_id => user.id)
  }

  BRANCH_NAME = "pixie"
  
  def base_path
    Rails.root.join 'public', 'production', 'projects'
  end

  def path
    base_path.join(id.to_s).to_s
  end

  def git_util(*args)
    system 'script/git_util', path, *args
  end

  def init_repo_with_remote_origin
    git_util 'init'
    git_util 'add', '.'
    git_util 'commit', '-m', 'First commit!'
    git_util 'remote', 'add', 'origin', remote_origin
    git_util 'push', '-u', 'origin', 'master'
  end

  def clone_repo
    if git?
      FileUtils.mkdir_p path

      git_util "clone", remote_origin, path
      git_util 'checkout', '-b', BRANCH_NAME
    end
  end
  handle_asynchronously :clone_repo

  def git_commit_and_push
    git_util 'checkout', BRANCH_NAME

    #TODO: Maybe scope to specific files
    git_util "add", "."

    #TODO: Shell escape user display name and add to commit message
    git_util "commit", "-am", 'Modified in browser at pixie.strd6.com'

    git_util "push", '-u', "origin", BRANCH_NAME
  end
  handle_asynchronously :git_commit_and_push

  def save_file(path, contents)
    #TODO: Verify path is not sketch
    return if path.index ".."

    filepath = File.join self.path, path

    File.open(filepath, 'wb') do |file|
      file.write(contents)
    end

    if git?
      git_commit_and_push
    end
  end

  def file_info
    file_node_data path, path
  end

  def file_node_data(file_path, project_root_path)
    filename = File.basename file_path

    if File.directory? file_path
      {
        :name => filename,
        :ext => "directory",
        :files => Dir.new(file_path).map do |filename|
          next if filename[0...1] == "."

          file_node_data(File.join(file_path, filename), project_root_path)
        end.compact
      }
    elsif File.file? file_path
      ext = File.extname(filename)[1..-1]
      contents = File.read(file_path)
      {
        :name => filename,
        :contents => contents,
        :ext => ext,
        :size => File.size(file_path),
        :path => file_path.sub(project_root_path, ''),
      }
    end
  end

  def has_access?(user)
    #TODO: Project memberships

    user == self.user
  end

  def git?
    remote_origin
  end

  def import_files
    if import_zip
      # write zip file contents to project dir
      system 'unzip', import_zip.path, '-o', '-d', path
    end
  end
end
