desc 'Continuous Deployment'
task :cruise => ['db:migrate', :jhw, :test] do
  system 'cap deploy'
end

desc 'Run jasmine specs'
task :jhw do
  sh %[bundle exec jasmine-headless-webkit -q]
end

