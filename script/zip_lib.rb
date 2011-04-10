#!/usr/bin/env ruby

require 'fileutils'
include FileUtils

id = ARGV[0]
zip_file = "#{id}.zip"

cd "public/production/libraries/#{id}"
system 'zip', '-r', zip_file, "."
mv zip_file, ".."
