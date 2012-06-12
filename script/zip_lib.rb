#!/usr/bin/env ruby

require 'fileutils'
include FileUtils

id = ARGV[0]
env = ARGV[1]
zip_file = "#{id}.zip"

cd "public/#{env}/projects/#{id}"
system 'zip', '-r', zip_file, ".", "-x", ".git/*"
mv zip_file, ".."
