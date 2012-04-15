desc 'Continuous Deployment'
task :cruise => ['db:migrate', :jhw, :test] do
  system 'cap deploy'
end

desc 'Run jasmine specs'
task :jhw do
  sh %[xvfb-run bundle exec jasmine-headless-webkit -cq]
end

