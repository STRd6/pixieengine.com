namespace :slurp do
  desc "copy db from production to development"
  task :db do
    puts `scp -P 2112 67.207.139.110:/u/apps/pixie.strd6.com/shared/db/production.sqlite3 db/development.sqlite3`
  end

  desc "copy images from production to development"
  task :images do
    puts `rsync -av -e 'ssh -p 2112' 67.207.139.110:/u/apps/pixie.strd6.com/shared/production/images public/production`
  end
end
