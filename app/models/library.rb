class Library < ActiveRecord::Base
  belongs_to :user

  has_many :library_scripts
  has_many :scripts, :through => :library_scripts

  has_many :library_components
  has_many :component_libraries, :through => :library_components

  has_many :app_libraries

  def add_component_library(library)
    component_libraries << library
  end

  def add_script(script)
    scripts << script
  end

  def remove_script(script)
    library_scripts.find_by_script_id(script.id).destroy
  end

  def code
    #TODO: Include component libraries

    scripts.map(&:code).join(";\n")
  end

  def test
    scripts.map(&:test).join(";\n")
  end
  
  def base_path
    Rails.root.join 'public', 'production', 'libraries'
  end

  def path
    base_path.join(id.to_s).to_s
  end

  def zip_path
    base_path.join("#{id}.zip").to_s
  end

  def clear_export_dir
    system 'rm', '-rf', path
  end

  def export_files
    dir = path
    src_dir = File.join(dir, 'src')
    test_dir = File.join(dir, 'test')

    FileUtils.mkdir_p(src_dir)
    FileUtils.mkdir_p(test_dir)

    scripts.each do |script|
      open(File.join(src_dir, script.file_name), "w") do |f|
        f.write(script.src)
      end

      open(File.join(test_dir, script.file_name), "w") do |f|
        f.write(script.test_src)
      end
    end
  end

  def export_to_project(path)
    dir = path
    src_dir = File.join(dir, 'src', title.to_filename)
    test_dir = File.join(dir, 'test', title.to_filename)

    FileUtils.mkdir_p(src_dir)
    FileUtils.mkdir_p(test_dir)

    scripts.each do |script|
      open(File.join(src_dir, script.file_name), "w") do |f|
        f.write(script.src)
      end

      open(File.join(test_dir, script.file_name), "w") do |f|
        f.write(script.test_src)
      end
    end
  end

  def export_code_file(dest_path)
    lib_dir = File.join(dest_path, 'lib')

    FileUtils.mkdir_p(lib_dir)

    open(File.join(lib_dir, title.to_filename("js")), "w") do |f|
      f.write(code)
    end
  end

  def zip
    clear_export_dir
    export_files
    system 'ruby', 'script/zip_lib.rb', id.to_s
  end
end
