require File.expand_path("#{File.dirname(__FILE__)}/../require")

require "active_record"

ActiveRecord::Base.extend(ActsAsArchive::Base::ActMethods)
ActiveRecord::Migration.send(:include, ActsAsArchive::Migration)