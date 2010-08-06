class User < ActiveRecord::Base
  acts_as_authentic do |config|
    config.validate_email_field :no_connected_sites?
    config.validate_password_field :no_connected_sites?
    config.require_password_confirmation = false
  end

  has_attached_file :avatar,
    :storage => :s3,
    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
    :path => "avatars/:id/:style.:extension",
    :styles => {
      :large => ["256x256>", :png],
      :thumb => ["32x32>", :png]
    }

  include Commentable

  has_many :libraries
  has_many :collections
  has_many :sprites
  has_many :invites

  has_many :authored_comments, :class_name => "Comment", :foreign_key => "commenter_id"
  has_many :authored_plugins, :class_name => "Plugin"
  has_many :user_plugins
  has_many :installed_plugins, :through => :user_plugins, :class_name => "Plugin", :source => :plugin

  attr_accessible :avatar, :display_name, :email, :password, :profile

  after_create do
    Notifier.welcome_email(self).deliver unless email.blank?
  end

  def to_s
    display_name
  end

  def send_forgot_password_email
    Notifier.forgot_password(self).deliver
  end

  def add_to_collection(item, collection_name="favorites")
    unless collection = collections.find_by_name(collection_name)
      collection = collections.create :name => collection_name
    end

    collection.collection_items.create(:item => item)
  end

  def remove_from_collection(item, collection_name="favorites")
    if collection = collections.find_by_name(collection_name)
      collection.collection_items.find_by_item(item).each(&:destroy)
    end
  end

  def remove_favorite(sprite)
    remove_from_collection(sprite)
  end

  def favorite?(sprite)
    collections.find_or_create_by_name("favorites").collection_items.find_by_item(sprite).first
  end

  def favorites_count
    collections.find_or_create_by_name("favorites").collection_items.count
  end

  def broadcast(message)
    if Rails.env.development?
      logger.info("USER[#{id}] BROADCASTING: #{message}")
      return
    end

    if twitter = authenticated_with?(:twitter)
      twitter.post("/statuses/update.json",
        "status" => message
      )
    end
  end

  def display_name
    if super.blank?
      "Anonymous#{id}"
    else
      super
    end
  end

  def install_plugin(plugin)
    installed_plugins << plugin
  end

  def uninstall_plugin(plugin)
    user_plugins.find_by_plugin_id(plugin).destroy
  end

  def plugin_installed?(plugin)
    installed_plugins.include? plugin
  end
  
  def progress
    total = 0
    tasks = []
    color = "red"

    if !self.profile.nil? && self.profile.length > 0
      total += 5
      tasks << "Complete profile description"
    end

    if self.sprites.length > 0
      total += 50
      tasks << "Create a sprite"
    end

    if !self.avatar_file_size.nil?
      total += 10
      tasks << "Choose an avatar"
    end

    if self.authored_comments.length > 0
      total += 10
      tasks << "Write a comment"
    end

    if self.favorites_count > 0
      total += 10
      tasks << "Find a favorite"
    end

    if self.invites.length == 1
      total += 5
      tasks << "Invite a friend"
    elsif self.invites.length == 2
      total += 10
      tasks << "Invite 2 friends"
    elsif self.invites.length >= 3
      total += 15
      tasks << "Invite 3 or more friends"
    end

    if (34..66) === total
      color = "yellow"
    elsif (67..100) === total
      color = "green"
    end

    remaining_tasks = [
      "Complete profile description",
      "Create a sprite",
      "Choose an avatar",
      "Write a comment",
      "Find a favorite",
      "Invite 3 or more friends"
      ] - tasks

    return {
      :total => total,
      :tasks => tasks,
      :color => color,
      :remaining_tasks => remaining_tasks
    }

  end

  def invite(options)
    invites.create(options)
  end

  private

  def no_connected_sites?
    authenticated_with.length == 0
  end
end
