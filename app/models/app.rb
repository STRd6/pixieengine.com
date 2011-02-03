class App < ActiveRecord::Base
  belongs_to :user
  belongs_to :parent, :class_name => "App"

  has_many :app_libraries
  has_many :libraries, :through => :app_libraries

  has_many :app_sprites
  has_many :sprites, :through => :app_sprites

  has_many :app_sounds
  has_many :sounds, :through => :app_sounds

  has_many :app_members
  has_many :members, :through => :app_members, :source => :user

  has_many :app_data

  after_save :generate_docs

  def resource_code
    return "var App = #{
      {
        :Sprites => app_sprites.inject({}) { |hash, app_sprite| hash[app_sprite.name] = app_sprite.sprite_id; hash},
        :Data => Hash[app_data.map { |datum| [datum.name, datum.json] }],
        :height => height,
        :width => width
      }.to_json
    };"
  end

  def library_code
    libraries.map(&:code).join(";\n")
  end

  def add_library(library)
    libraries << library
  end

  def remove_library(library)
    app_libraries.find_by_library_id(library.id).destroy
  end

  def template
    "<canvas width='#{width}' height='#{height}'></canvas>"
  end

  def wrapped_code
    "$(function(){ #{code} });"
  end

  def has_access?(user)
    user == self.user || members.exists?(user)
  end

  def publish
    dir = "public/production/apps/#{id}"

    FileUtils.mkdir_p(dir)

    open("#{dir}/published.js", "w") do |f|
      f.write(resource_code)
      f.write(library_code)
      f.write(wrapped_code)
    end
  end

  def generate_docs
    Dir.mktmpdir do |dir|
      jsdoc_toolkit_dir = JSDoc::TOOLKIT_DIR
      doc_dir = "public/production/apps/#{id}/docs/"

      open("#{dir}/lib.js", "w") {|f| f.write(library_code)}
      open("#{dir}/app.js", "w") {|f| f.write(code)}

      FileUtils.mkdir_p(doc_dir)

      cmd = "java -jar #{jsdoc_toolkit_dir}jsrun.jar #{jsdoc_toolkit_dir}app/run.js #{dir} -c=config/jsdoc.conf -d=#{doc_dir}"
      system(cmd)
    end
  end
  handle_asynchronously :generate_docs
end
