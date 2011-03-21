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
      :test => "test",
      :lib => "lib",
      :compiled => "compiled",
    },
    :width => 640,
    :height => 480,
    :main => "main.coffee",
    :wrapMain => true,
    :hotSwap => true,
  }
  BRANCH_NAME = "pixie"
  
  def base_path
    Rails.root.join 'public', 'production', 'projects'
  end

  def path
    base_path.join(id.to_s).to_s
  end

  def config_path
    File.join path, "pixie.json"
  end

  def create_directory
    FileUtils.mkdir_p path
    system 'chmod', "g+w", path
  end

  def make_group_writable
    system 'chmod', "g+w", '-R', path
    system "sudo", "-u", "gitbot", 'chmod', "g+w", '-R', path
  end

  def update_libs
    lib_path = File.join path, config[:directories][:lib]

    config[:libs].each do |filename, url|
      file_path = File.join lib_path, filename

      File.open(file_path, 'wb') do |file|
        file.write(open(url) {|f| f.read})
      end
    end
  end
  handle_asynchronously :update_libs

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

  def tag_version(tag, message)
    if git?
      git_util 'tag', '-am', message, tag
      git_util 'push', '--tags'
    end
  end
  handle_asynchronously :tag_version

  def clone_repo
    if git?
      git_util "clone", remote_origin, path
      # Try to checkout remote branch if it exists
      git_util 'checkout', '-t', "origin/#{BRANCH_NAME}"
      # Try to create branch in case previous command failed
      git_util 'checkout', '-b', BRANCH_NAME
      # Push branch if it was just created
      git_util "push", '-u', "origin", BRANCH_NAME
    end

    make_group_writable
  end
  handle_asynchronously :clone_repo

  def git_pull
    git_util "pull"
    make_group_writable
  end
  handle_asynchronously :git_pull

  def git_commit_and_push(message)
    git_util 'checkout', BRANCH_NAME

    #TODO: Maybe scope to specific files
    git_util "add", "."

    git_util "commit", "-am", message, "--author", "#{user.display_name} <#{user.email}>"

    git_util "push", '-u', "origin", BRANCH_NAME
  end
  handle_asynchronously :git_commit_and_push

  def save_file(path, contents, message=nil)
    #TODO: Verify path is not sketch
    return if path.index ".."

    file_path = File.join self.path, path

    dir_path = file_path.split("/")[0...-1].join("/")
    FileUtils.mkdir_p dir_path

    File.open(file_path, 'wb') do |file|
      file.write(contents)
    end

    if git?
      git_commit_and_push(message || "Modified in browser at pixie.strd6.com")
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
      if filename == "docs"
        {
          :name => "Documentation",
          :ext => "documentation",
          :path => file_path.sub(project_root_path, '')
        }
      else
        {
          :name => filename,
          :ext => "directory",
          :files => Dir.new(file_path).map do |filename|
            next if filename[0...1] == "."

            file_node_data(File.join(file_path, filename), project_root_path)
          end.compact.sort_by do |file_data|
            [file_data[:ext] == "directory" ? 0 : 1, file_data[:name]]
          end
        }
      end
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

  def generate_docs
    Dir.mktmpdir do |dir|
      jsdoc_toolkit_dir = JSDoc::TOOLKIT_DIR
      doc_dir = File.join path, "docs"

      FileUtils.cp File.join(path, "#{title}.js"), dir

      FileUtils.mkdir_p(doc_dir)

      cmd = "java -jar #{jsdoc_toolkit_dir}jsrun.jar #{jsdoc_toolkit_dir}app/run.js #{dir} -c=config/jsdoc.conf -d=#{doc_dir}"
      system(cmd)
    end
  end
  handle_asynchronously :generate_docs

  def config
    @config ||= HashWithIndifferentAccess.new(JSON.parse(File.read(config_path)))
  end
end
