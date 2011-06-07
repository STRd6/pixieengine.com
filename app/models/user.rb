class User < ActiveRecord::Base
  acts_as_authentic do |config|
    config.validate_email_field :no_connected_sites?
    config.validate_password_field :no_connected_sites?
    config.require_password_confirmation = false
  end

  has_attached_file :avatar, S3_OPTS.merge(
    :path => "avatars/:id/:style.:extension",
    :styles => {
      :large => ["256x256>", :png],
      :thumb => ["32x32>", :png]
    }
  )

  include Commentable

  has_many :libraries
  has_many :collections
  has_many :sprites,
    :order => "id DESC"
  has_many :invites

  has_many :projects,
    :order => "id DESC"

  has_many :authored_comments, :class_name => "Comment", :foreign_key => "commenter_id"
  has_many :authored_plugins, :class_name => "Plugin"
  has_many :user_plugins
  has_many :installed_plugins, :through => :user_plugins, :class_name => "Plugin", :source => :plugin

  attr_accessible :avatar, :display_name, :email, :password, :profile, :favorite_color

  scope :online_now, lambda {
    where("last_request_at >= ?", Time.zone.now - 15.minutes)
  }

  scope :featured, where("avatar_file_size IS NOT NULL AND profile IS NOT NULL")

  scope :none

  after_create do
    Notifier.welcome_email(self).deliver unless email.blank?
  end

  def to_s
    display_name
  end

  def demo_project
    project = projects.where(:demo => true).first

    unless project
      project = projects.create! :demo => true, :title => "Demo", :description => "A demo project to help you get started"
    end

    return project
  end

  def send_forgot_password_email
    Notifier.forgot_password(self).deliver
  end

  def self.send_newsletter_email
    User.all(:conditions => {:subscribed => true}).each do |user|
      Notifier.newsletter(user).deliver  unless user.email.blank?
    end
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

  def set_avatar(sprite)
    self.avatar = sprite.image
    self.save
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

  def to_param
    "#{id}-#{display_name.seo_url}"
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

  def invite(options)
    invites.create(options)
  end

  def tasks
    [
      {
        :description => "Create a sprite",
        :value => 40,
        :complete? => sprites.length > 0,
        :link => {:action => :new, :controller => :sprites},
      },
      {
        :description => "Fill out your profile",
        :value => 10,
        :complete? => profile && profile.length > 0,
        :link => {:action => :edit, :id => id, :controller => :users},
      },
      {
        :description => "Upload an avatar",
        :value => 10,
        :complete? => avatar_file_size,
        :link => {:action => :edit, :id => id, :controller => :users},
      },
      {
        :description => "Find three favorites",
        :value => 10,
        :complete? => favorites_count > 2,
        :link => {:action => :index, :controller => :sprites},
      },
      {
        :description => "Leave a comment",
        :value => 10,
        :complete? => authored_comments.length > 0,
        :link => {:action => :index, :controller => :sprites},
      },
      {
        :description => "Invite a friend",
        :value => 10,
        :complete? => invites.length > 0,
        :link => {:action => :new, :controller => :invites},
      },
      {
        :description => "Invite another friend",
        :value => 5,
        :complete? => invites.length > 1,
        :link => {:action => :new, :controller => :invites},
      },
      {
        :description => "Invite a third friend",
        :value => 5,
        :complete? => invites.length > 2,
        :link => {:action => :new, :controller => :invites},
      }
    ]
  end

  def subscribe_url
    "https://spreedly.com/pixie/subscribers/#{id}/subscribe/10491/#{display_name}?email=#{email}"
  end

  def refresh_from_spreedly
    subscriber = Subscriber.find(self.id)

    if subscriber
      self.update_attribute(:paying, subscriber.active)
    else
      self.update_attribute(:paying, false)
    end
  end

  def self.visit_report
    esac = "
      CASE
        WHEN login_count BETWEEN 0 AND 1 THEN 0
        WHEN login_count BETWEEN 2 AND 5 THEN 1
        WHEN login_count BETWEEN 6 AND 12 THEN 2
        ELSE 3
      END
    "
    User.select("COUNT(*) AS count, #{esac} AS segment").group(esac)
  end

  private

  def no_connected_sites?
    authenticated_with.length == 0
  end
end
