namespace :projects do
  # Update the libs for the demo project
  task :update_libs => :environment do
    Project.find(34).update_libs
  end
end
