namespace :doc do
  task :pixie => :environment do
    dir = "/assets/pixie"
    output_dir = "public/system/docs/pixie"
    jsdoc_toolkit_dir = JSDoc::TOOLKIT_DIR

    FileUtils.mkdir_p(output_dir)

    cmd = "java -jar #{jsdoc_toolkit_dir}jsrun.jar #{jsdoc_toolkit_dir}app/run.js #{dir} -c=config/jsdoc.conf -d=#{output_dir}"
    system(cmd)
  end
end
