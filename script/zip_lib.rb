#!/usr/bin/env ruby

require 'fileutils'
include FileUtils

id = ARGV[0]
type = ARGV[1] || "libraries"
zip_file = "#{id}.zip"

cd "public/production/#{type}/#{id}"
system 'zip', '-r', zip_file, ".", "-x", ".git/*"
mv zip_file, ".."
