class Project < ActiveRecord::Base
  include Commentable
  include Memberships

  acts_as_archive

  has_attached_file :image, S3_OPTS.merge(
    :path => "projects/:id/:style.:extension",
    :styles => {
      :tiny => ["16x16#", :png],
      :thumb => ["96x96#", :png],
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

  scope :search, lambda{ |search|
    return {} if search.blank?

    like = "%#{search}%".downcase

    where("lower(title) like ?", like)
  }

  scope :featured, where(:featured => true)
  scope :tutorials, where(:tutorial => true).order('id ASC')
  scope :arcade, where(:arcade => true)
  scope :recently_edited, order('updated_at DESC').limit(20)

  scope :none

  DEFAULT_CONFIG = {
    :directories => {
      :animations => "animations",
      :data => "data",
      :entities => "entities",
      :images => "images",
      :lib => "lib",
      :sounds => "sounds",
      :source => "src",
      :test => "test",
      :test_lib => "test_lib",
      :tilemaps => "tilemaps",
    },
    :width => 480,
    :height => 320,
    :library => false,
    :main => "main",
    :wrapMain => true,
    :hotSwap => true,
  }
  BRANCH_NAME = "pixie"
  DEMO_ORIGIN = "git://github.com/STRd6/PixieDemo.git"
  DOCS_ID = 34
  DEMO_ID = 176
  JUMP_DEMO_ID = 218
  SHOOT_DEMO_ID = 227
  ASTEROIDS_DEMO_ID = 123
  MAX_EDITOR_FILE_SIZE = 100_000

  def self.editable(user)
    Project.find_by_sql <<-eos
      (
      SELECT projects.*
      FROM memberships
      INNER JOIN projects
        ON memberships.group_id = projects.id
      WHERE memberships.user_id = #{user.id}
      UNION
      SELECT projects.*
      FROM projects
      WHERE projects.user_id = #{user.id}
      )
      ORDER BY updated_at DESC
      eos
  end

  def as_json(options={})
    {
      :description => description,
      :id => id,
      :title => title,
      :user_id => user_id,
      :owner_name => user.display_name,
      :img => image.url(:thumb)
    }
  end

  def display_name
    title
  end

  def base_url
    "/production/projects/#{id}/"
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
    system "chown", "rails:users", "-R", path
    system "chmod", "g+w", "-R", path
  end

  def update_libs
    lib_path = File.join path, config[:directories][:lib]
    FileUtils.mkdir_p lib_path

    (config[:libs] || []).each do |filename, url|
      file_path = File.join lib_path, filename

      File.open(file_path, 'wb') do |file|
        file.write(open(url) {|f| f.read})
      end
    end

    # These libs are for testing only (aka non-bundled dependencies)
    test_lib_path = File.join path, (config[:directories][:test_lib] || DEFAULT_CONFIG[:directories][:test_lib])
    FileUtils.mkdir_p test_lib_path

    (config[:test_libs] || []).each do |filename, url|
      file_path = File.join test_lib_path, filename

      File.open(file_path, 'wb') do |file|
        file.write(open(url) {|f| f.read})
      end
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
    # Cloning repos in tests is way too scary
    return if Rails.env.test?

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

    set_config_author_data
    make_group_writable
  end

  def git_pull
    git_util "pull"
    make_group_writable
  end
  handle_asynchronously :git_pull

  def git_commit_and_push(authoring_user_id, message)
    message ||= "Modified in browser at pixie.strd6.com"
    git_util 'checkout', BRANCH_NAME

    #TODO: Maybe scope to specific files
    git_util "add", "."

    authoring_user = User.find authoring_user_id

    #TODO: Tracking actual person who commits now that projects can have members
    git_util "commit", "-am", message, "--author", "#{authoring_user.display_name} <#{authoring_user.email}>"

    if push_enabled?
      git_util "push", '-u', "origin", BRANCH_NAME
    end
  end
  handle_asynchronously :git_commit_and_push

  def save_file(path, contents, authoring_user, message=nil)
    #TODO: Verify path is not sketch
    return if path.index ".."

    touch
    file_path = File.join self.path, path

    dir_path = file_path.split("/")[0...-1].join("/")
    FileUtils.mkdir_p dir_path

    File.open(file_path, 'wb') do |file|
      file.write(contents)
    end

    git_commit_and_push_without_delay(authoring_user.id, message) if Rails.env.production?
  end
  handle_asynchronously :save_file if Rails.env.production?

  def remove_file(path, authoring_user, message=nil)
    #TODO: Verify path is not sketch
    return if path.index ".."
    return if path.first == "/"

    #TODO Handle directories

    FileUtils.rm File.join(self.path, path)
    git_util "rm", path

    git_commit_and_push(authoring_user.id, message)
  end

  def rename_file(path, new_path, authoring_user, message=nil)
    #TODO: Verify path is not sketch
    return if path.index ".."
    return if path.first == "/"

    return if new_path.index ".."
    return if new_path.first == "/"

    FileUtils.mv File.join(self.path, path), File.join(self.path, new_path)
    git_util "mv", path, new_path

    git_commit_and_push(authoring_user.id, message)
  end

  def file_info
    file_node_data(path, path)
  end

  def doc_selector(path)
    selector = path.gsub('.', '_').gsub('/', '_')

    '#file_' + selector
  end

  def file_node_data(file_path, project_root_path)
    filename = File.basename file_path
    filename = "" if filename == id.to_s

    path = file_path.sub(project_root_path + File::SEPARATOR, '')

    if File.directory? file_path
      if filename == "docs"
        {
          :name => "Documentation",
          :extension => "documentation",
          :path => path,
        }
      else
        {
          :name => filename,
          :files => Dir.new(file_path).map do |filename|
            next if filename[0...1] == "."

            file_node_data(File.join(file_path, filename), project_root_path)
          end.compact
        }
      end
    elsif File.file? file_path
      ext = (File.extname(filename)[1..-1] || "").downcase
      name = filename.sub(/\.[^\.]*$/, '')
      lang = lang_for(ext)

      if path == "#{config[:name]}.js" || file_path == "#{title}.js"
        # This is a 'compiled' JavaScript file for the project
        type = "binary"
      else
        type = type_for(ext)
      end

      if ["text", "json", "tilemap", "animation", "entity", "tutorial", "link", "macro"].include? type
        contents = File.read(file_path)
      elsif ext == "sfs"
        contents = open(file_path, "rb") do |file|
          Base64.encode64(file.read())
        end
      end

      {
        :name => name,
        :contents => contents,
        :docSelector => doc_selector(path),
        :extension => ext,
        :language => lang,
        :type => type,
        :size => File.size(file_path),
        :mtime => File.mtime(file_path).to_i,
        :path => path,
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
    when "", "js", "coffee", "html", "css", "lua", "cfg", "md", "markdown"
      "text"
    when "json"
      "json"
    when "png", "jpg", "jpeg", "gif", "bmp"
      "image"
    when "sfs"
      "sound"
    when "wav", "mp3"
      "binary"
    when "tilemap"
      "tilemap"
    when "entity"
      "entity"
    when "animation"
      "animation"
    when "tutorial"
      "tutorial"
    end
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

  def set_config_author_data
    if File.exist? config_path
      current_config = HashWithIndifferentAccess.new(JSON.parse(File.read(config_path)))

      current_config[:name] = title
      current_config[:author] = user.display_name

      File.open(config_path, 'w') do |file|
        file.write(JSON.pretty_generate(current_config))
      end
    end
  end

  def manifest_path
    File.join path, "manifest.json"
  end

  def webstore_asset_path
    File.join path, "webstore"
  end

  def prepare_for_web_store
    images_dir = File.join(webstore_asset_path, "images")
    icon_path = File.join(images_dir, "icon_")
    main_html_path = File.join(webstore_asset_path, "main.html")

    FileUtils.mkdir_p images_dir

    if image.exists?
      File.open(icon_path + "16.png", 'wb') do |file|
        file.write(open(image.url(:tiny)) {|f| f.read})
      end

      File.open(icon_path + "96.png", 'wb') do |file|
        file.write(open(image.url(:thumb)) {|f| f.read})
      end

      `mogrify -background transparent -gravity center -extent 128x128 -write #{icon_path}128.png #{icon_path}96.png`
    else
      %w[128 96 16].each do |size|
        FileUtils.cp Rails.root.join("app", "export", "images", "webstore_#{size}.png"), icon_path + "#{size}.png"
      end
    end

    FileUtils.cp Rails.root.join("app", "export", "stylesheets", "project.css"), webstore_asset_path
    FileUtils.cp Rails.root.join("app", "export", "javascripts", "jquery.min.js"), webstore_asset_path

    File.open(main_html_path, 'wb') do |file|
      file.write <<-eof
        <html>
        <head>
          <link href="/webstore/project.css" media="screen" rel="stylesheet" type="text/css">
          <script src="/webstore/jquery.min.js" type="text/javascript"></script>
        </head>
        <body class="contents_centered">
          <canvas width="#{config[:width]}" height="#{config[:height]}"></canvas>
          <script>BASE_URL = "../"; MTIME = "#{Time.now.to_i}";</script>
          <script src="/#{config[:name]}.js"></script>
        </body>
        </html>
      eof
    end

    write_manifest_json
  end

  def write_manifest_json
    current_manifest = if File.exist? manifest_path
      HashWithIndifferentAccess.new(JSON.parse(File.read(manifest_path)))
    else
      {}
    end

    current_version = if config[:version]
      config[:version]
    elsif previous_version = current_manifest[:version]
      version_pieces = previous_version.split(".")
      (version_pieces[0...-1] + [version_pieces.last.to_i + 1]).join(".")
    else
      "0.0.1"
    end

    manifest_json = current_manifest.merge({
      :name => title,
      # Truncate description to max of 132 characters for Chrome
      :description => description[0...132],
      :app => {
        :launch => {
          :local_path => "webstore/main.html",
        }
      },
      :version => current_version,
      :icons => {
        "128" => "webstore/images/icon_128.png",
        "96" => "webstore/images/icon_96.png",
        "16" => "webstore/images/icon_16.png",
      }
    })

    File.open(manifest_path, 'wb') do |file|
      file.write(JSON.pretty_generate(manifest_json))
    end
  end
end
