desc 'Continuous Deployment'
task :cruise =>['db:migrate', :test] do
  system 'cap deploy'
end
