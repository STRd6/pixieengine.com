
task :bootstrap do
  #TODO figure out how to get real configs bootstrapped easily

  %w[database settings s3 oauth].each do |file|
    `if [ ! -e config/#{file}.yml ]; then cp config/#{file}_example.yml config/#{file}.yml; fi`
  end
end
