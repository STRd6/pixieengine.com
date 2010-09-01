class App < ActiveRecord::Base
  belongs_to :user
  belongs_to :parent, :class_name => "App"

  has_many :app_libraries
  has_many :libraries, :through => :app_libraries

  after_save :generate_docs

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
    #TODO Not hardcoded
    '<canvas width="640" height="480"></canvas>'
  end

  def generate_docs
    Dir.mktmpdir do |dir|
      jsdoc_toolkit_dir = "vendor/jsdoc-toolkit/"
      doc_dir = "public/apps/#{id}/docs/"

      open("#{dir}/lib.js", "w") {|f| f.write(library_code)}
      open("#{dir}/app.js", "w") {|f| f.write(code)}

      FileUtils.mkdir_p(doc_dir)

      cmd = "java -jar #{jsdoc_toolkit_dir}jsrun.jar #{jsdoc_toolkit_dir}app/run.js #{dir} -c=config/jsdoc.conf -d=#{doc_dir}"
      system(cmd)
    end
  end
end
