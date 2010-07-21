# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100721041022) do

  create_table "access_tokens", :force => true do |t|
    t.integer  "user_id"
    t.string   "type",       :limit => 30
    t.string   "key"
    t.string   "token",      :limit => 1024
    t.string   "secret"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "access_tokens", ["key"], :name => "index_access_tokens_on_key", :unique => true

  create_table "alternatives", :force => true do |t|
    t.integer "experiment_id"
    t.string  "content"
    t.string  "lookup",        :limit => 32
    t.integer "weight",                      :default => 1
    t.integer "participants",                :default => 0
    t.integer "conversions",                 :default => 0
  end

  add_index "alternatives", ["experiment_id"], :name => "index_alternatives_on_experiment_id"
  add_index "alternatives", ["lookup"], :name => "index_alternatives_on_lookup"

  create_table "collection_items", :force => true do |t|
    t.integer  "collection_id", :null => false
    t.integer  "item_id",       :null => false
    t.string   "item_type",     :null => false
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "collection_items", ["collection_id"], :name => "index_collection_items_on_collection_id"
  add_index "collection_items", ["item_id", "item_type"], :name => "index_collection_items_on_item_id_and_item_type"

  create_table "collections", :force => true do |t|
    t.integer  "user_id",                       :null => false
    t.string   "name",                          :null => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.integer  "comments_count", :default => 0, :null => false
  end

  add_index "collections", ["user_id"], :name => "index_collections_on_user_id"

  create_table "comments", :force => true do |t|
    t.integer  "commenter_id",     :null => false
    t.integer  "commentable_id",   :null => false
    t.string   "commentable_type", :null => false
    t.text     "body",             :null => false
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "comments", ["commentable_id", "commentable_type"], :name => "index_comments_on_commentable_id_and_commentable_type"
  add_index "comments", ["commenter_id"], :name => "index_comments_on_commenter_id"

  create_table "experiments", :force => true do |t|
    t.string   "test_name"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "experiments", ["test_name"], :name => "index_experiments_on_test_name"

  create_table "feedbacks", :force => true do |t|
    t.integer  "user_id"
    t.text     "body",          :null => false
    t.string   "email_address"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "links", :force => true do |t|
    t.integer  "user_id",                   :null => false
    t.integer  "target_id",                 :null => false
    t.string   "target_type",               :null => false
    t.string   "token",       :limit => 16, :null => false
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "links", ["token"], :name => "index_links_on_token", :unique => true

  create_table "plugins", :force => true do |t|
    t.integer  "user_id"
    t.boolean  "approved",    :default => false, :null => false
    t.string   "plugin_type",                    :null => false
    t.string   "title",                          :null => false
    t.text     "description"
    t.text     "code",                           :null => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "parent_id"
  end

  create_table "sprites", :force => true do |t|
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.integer  "width",                         :null => false
    t.integer  "height",                        :null => false
    t.integer  "frames",         :default => 1, :null => false
    t.integer  "user_id"
    t.string   "title"
    t.text     "description"
    t.integer  "parent_id"
    t.integer  "comments_count", :default => 0, :null => false
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id",        :null => false
    t.integer  "taggable_id",   :null => false
    t.string   "taggable_type", :null => false
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       :null => false
    t.datetime "created_at",    :null => false
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token",                      :null => false
    t.string   "single_access_token",                    :null => false
    t.string   "perishable_token",                       :null => false
    t.integer  "login_count",         :default => 0,     :null => false
    t.integer  "failed_login_count",  :default => 0,     :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "display_name"
    t.integer  "referrer_id"
    t.string   "oauth_token"
    t.string   "oauth_secret"
    t.integer  "active_token_id"
    t.boolean  "admin",               :default => false, :null => false
    t.integer  "comments_count",      :default => 0,     :null => false
    t.text     "profile"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
  end

  add_index "users", ["oauth_token"], :name => "index_users_on_oauth_token"

end
