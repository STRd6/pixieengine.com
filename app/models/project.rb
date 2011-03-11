class Project < ActiveRecord::Base
  belongs_to :user

  before_validation :update_hook_url

  after_save :create_directory
  after_save :import_files

  after_create :clone_repo

  attr_accessor :import_zip

  scope :for_user, lambda {|user|
    where(:user_id => user.id)
  }

  scope :with_url, lambda {|url|
    where :url => url
  }

  DEFAULT_CONFIG = {
    :directories => {
      :images => "images",
      :sounds => "sounds",
      :source => "src",
      :compiled => "compiled",
    },
    :width => 640,
    :height => 320,
    :wrap_main => true,
  }
  BRANCH_NAME = "pixie"
  
  def base_path
    Rails.root.join 'public', 'production', 'projects'
  end

  def path
    base_path.join(id.to_s).to_s
  end

  def create_directory
    FileUtils.mkdir_p path
    system 'chmod', "g+w", path
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

  def git_tag(tag, message)
    git_util 'tag', '-am', message, tag
    git_util 'push', '--tags'
  end

  def clone_repo
    if git?
      git_util "clone", remote_origin, path
      git_util 'checkout', '-b', BRANCH_NAME
    end
  end
  handle_asynchronously :clone_repo

  def git_pull
    git_util "pull"
  end
  handle_asynchronously :git_pull

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

    file_path = File.join self.path, path

    dir_path = file_path.split("/")[0...-1].join("/")
    FileUtils.mkdir_p dir_path

    File.open(file_path, 'wb') do |file|
      file.write(contents)
    end

    if git?
      git_commit_and_push
    end
  end

  def remove_file(path)
    #TODO: Verify path is not sketch
    return if path.index ".."

    #TODO Handle directories

    if git?
      git_util "rm", path

      git_commit_and_push
    else
      FileUtils.rm File.join(self.path, path)
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
        :files => Dir.new(file_path).sort.map do |filename|
          next if filename[0...1] == "."

          file_node_data(File.join(file_path, filename), project_root_path)
        end.compact
      }
    elsif File.file? file_path
      ext = (File.extname(filename)[1..-1] || "").downcase
      lang = lang_for(ext)
      type = type_for(ext)

      if type == "text"
        contents = File.read(file_path)
      elsif ext == "sfs"
        contents = open(file_path, "rb") do |file|
          Base64.encode64(file.read())
        end
      end

      {
        :name => filename,
        :contents => contents,
        :ext => ext,
        :lang => lang,
        :type => type,
        :size => File.size(file_path),
        :mtime => File.mtime(file_path).to_i,
        :path => file_path.sub(project_root_path, ''),
      }
    end
  end

  def lang_for(extension)
    case extension
    when "js", "json"
      "javascript"
    when "coffee"
      "coffeescript"
    when "html", "css"
      extension
    end
  end

  def type_for(extension)
    case extension
    when "", "js", "json", "coffee", "html", "css", "lua", "cfg"
      "text"
    when "png", "jpg", "jpeg", "gif", "bmp"
      "image"
    when "sfs"
      "sound"
    when "wav", "mp3"
      "binary"
    end
  end

  def has_access?(user)
    #TODO: Project memberships

    user == self.user
  end

  def git?
    remote_origin
  end

  def update_hook_url
    unless remote_origin.blank?
      url = "https://github.com/" + remote_origin.gsub(".git", '').split(":")[-1].split("/")[-2..-1].join("/")
      self.url = url
    end
  end

  def import_files
    if import_zip
      # write zip file contents to project dir
      system 'unzip', import_zip.path, '-o', '-d', path
    end
  end
end
