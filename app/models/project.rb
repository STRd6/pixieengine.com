class Project < ActiveRecord::Base
  include Commentable

  has_attached_file :image, S3_OPTS.merge(
    :path => "projects/:id/:style.:extension",
    :styles => {
      :thumb => ["96x96#", :png]
    }
  )

  belongs_to :user
  belongs_to :parent, :class_name => "Project"

  before_validation :update_hook_url

  after_save :create_directory
  after_save :import_files

  after_create :clone_repo

  validates_presence_of :title

  attr_accessor :import_zip

  scope :for_user, lambda {|user|
    where(:user_id => user.id)
  }

  scope :with_url, lambda {|url|
    where :url => url
  }

  scope :featured, where(:featured => true)
  scope :tutorial, where(:tutorial => true)
  scope :arcade, where(:arcade => true)

  scope :none

  DEFAULT_CONFIG = {
    :directories => {
      :data => "data",
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
  DEMO_ORIGIN = "git://github.com/STRd6/PixieDemo.git"
  DEMO_ID = 34

  def display_name
    title
  end

  def demo_path
    File.join base_path, DEMO_ID.to_s
  end

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
    unless demo? || parent
      FileUtils.mkdir_p path
      system 'chmod', "g+w", path
    end
  end

  def make_group_writable
    system 'chmod', "g+w", '-R', path
    system "sudo", "-u", "gitbot", 'chmod', "g+w", '-R', path
  end

  def update_libs
    lib_path = File.join path, config[:directories][:lib]

    FileUtils.mkdir_p lib_path

    config[:libs].each do |filename, url|
      file_path = File.join lib_path, filename

      File.open(file_path, 'wb') do |file|
        file.write(open(url) {|f| f.read})
      end

      Juggernaut.publish("/projects/#{id}/#{url}", {
        filename => IO.read(file_path)
      })
    end

    make_group_writable
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
    git_util 'tag', '-am', message, tag

    if push_enabled?
      git_util 'push', '--tags'
    end
  end
  handle_asynchronously :tag_version

  def clone_repo
    create_directory unless demo? || parent

    if remote_origin.present?
      git_util "clone", remote_origin, path
      # Try to checkout remote branch if it exists
      git_util 'checkout', '-t', "origin/#{BRANCH_NAME}"
      # Try to create branch in case previous command failed
      git_util 'checkout', '-b', BRANCH_NAME
      # Push branch if it was just created
      git_util "push", '-u', "origin", BRANCH_NAME
    else
      if demo?
        FileUtils.cp_r demo_path, path
      elsif parent
        FileUtils.cp_r parent.path, path
      else
        # Clone Demo Project
        git_util "clone", DEMO_ORIGIN, path
        # Checkout local pixie branch
        git_util 'checkout', '-b', BRANCH_NAME
      end
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
    message ||= "Modified in browser at pixie.strd6.com"
    git_util 'checkout', BRANCH_NAME

    #TODO: Maybe scope to specific files
    git_util "add", "."

    git_util "commit", "-am", message, "--author", "#{user.display_name} <#{user.email}>"

    if push_enabled?
      git_util "push", '-u', "origin", BRANCH_NAME
    end
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

    git_commit_and_push_without_delay(message) if Rails.env.production?
  end
  handle_asynchronously :save_file if Rails.env.production?

  def remove_file(path, message=nil)
    #TODO: Verify path is not sketch
    return if path.index ".."
    return if path.first == "/"

    #TODO Handle directories

    FileUtils.rm File.join(self.path, path)
    git_util "rm", path

    git_commit_and_push(message)
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
          :path => file_path.sub(project_root_path + File::SEPARATOR, '')
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

      if type == "text" || type == "tilemap"
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
        :path => file_path.sub(project_root_path + File::SEPARATOR, ''),
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
    when "tilemap"
      "tilemap"
    end
  end

  def has_access?(user)
    #TODO: Project memberships

    user == self.user
  end

  def push_enabled?
    remote_origin.present?
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

  def zip_path
    "#{path}.zip"
  end

  def zip_for_export
    system 'ruby', 'script/zip_lib.rb', id.to_s, self.class.table_name
  end

  def generate_docs
    Dir.mktmpdir do |dir|
      jsdoc_toolkit_dir = JSDoc::TOOLKIT_DIR
      doc_dir = File.join path, "docs"

      FileUtils.cp File.join(path, "#{config[:name] || title}.js"), dir

      FileUtils.mkdir_p(doc_dir)

      cmd = "java -jar #{jsdoc_toolkit_dir}jsrun.jar #{jsdoc_toolkit_dir}app/run.js #{dir} -c=config/jsdoc.conf -d=#{doc_dir} -n -s"
      system(cmd)
    end
  end
  handle_asynchronously :generate_docs

  def config
    @config ||=
      if File.exist? config_path
        HashWithIndifferentAccess.new(JSON.parse(File.read(config_path))).reverse_merge(DEFAULT_CONFIG)
      else
        {}.merge(DEFAULT_CONFIG)
      end
  end
end
