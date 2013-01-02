class User < ActiveRecord::Base
  if Rails.env.production?
    SITE = "pixie"
    DEFAULT_PLAN_ID = 10491
  else
    SITE = "STRd6-test"
    DEFAULT_PLAN_ID = 9356
  end

  STUDENT_PLAN_ID = 18694
  INDIE_PLAN_ID = 18695

  validates :display_name,
    :format => { :with => /^[A-Za-z0-9_-]+$/ },
    :presence => true,
    :uniqueness => true

  acts_as_authentic do |config|
    config.validate_email_field :no_connected_sites?
    config.validate_password_field :no_connected_sites?
    config.require_password_confirmation = false
  end

  has_attached_file :avatar, S3_OPTS.merge(
    :path => "avatars/:id/:style.:extension",
    :styles => {
      :large => ["256x256>", :png],
      :thumb => ["32x32>", :png],
      :tiny => ["20x20#", :png],
    }
  )

  include Commentable
  include Oauthable

  has_many :libraries
  has_many :collections
  has_many :sprites,
    :order => "id DESC"
  has_many :invites

  has_many :projects,
    :order => "id DESC"

  has_many :visits

  has_many :authored_comments, :class_name => "Comment", :foreign_key => "commenter_id"
  has_many :authored_plugins, :class_name => "Plugin"
  has_many :memberships
  has_many :user_plugins
  has_many :installed_plugins, :through => :user_plugins, :class_name => "Plugin", :source => :plugin

  attr_accessible :avatar, :display_name, :email, :password, :profile, :favorite_color, :forum_notifications, :site_notifications, :help_tips

  scope :online_now, lambda {
    where("last_request_at >= ?", Time.zone.now - 15.minutes)
  }

  scope :search, lambda{ |search|
    return {} if search.blank?

    like = "%#{search}%".downcase

    where("lower(display_name) like ? OR lower(email) like ?", like, like)
  }

  scope :subscribed, where(:subscribed => true)

  scope :recently_active, lambda {
    where("last_request_at >= ?", Time.zone.now - 1.day)
  }

  scope :not_recently_surveyed, lambda {
    where("last_surveyed <= ?", Time.zone.now - 3.months)
  }

  # People who haven't been on recently (within a month)
  scope :inactive, lambda {
    where("last_request_at <= ?", Time.zone.now - 1.month)
  }

  # People we haven't emailed recently
  scope :not_recently_contacted, lambda {
    where("last_contacted <= ?", Time.zone.now - 1.month)
  }

  scope :recent_sprites, lambda {
    where("sprites.created_at >= ?", Time.zone.now - 1.week).joins(:sprites)
  }

  scope :featured, where("avatar_file_size IS NOT NULL AND profile IS NOT NULL")

  scope :none

  after_create :send_welcome_email

  before_validation :sanitize_profile

  def as_json(options={})
    {
      :display_name => display_name,
      :id => id,
      :avatar_src => avatar(:thumb),
      :description => profile
    }
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

  def self.send_newsletter_email(newsletter)
    failed_user_ids = []
    delivery_date = Time.now.strftime("%b %d %Y")

    User.order('id').subscribed.each do |user|
      begin
        Notifier.send_newsletter(user, newsletter, delivery_date).deliver unless user.email.blank?
      rescue
        failed_user_ids.push(user.id)
      end
    end

    return failed_user_ids
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

  def to_param
    display_name
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
        :link => [:edit, self],
      },
      {
        :description => "Upload an avatar",
        :value => 10,
        :complete? => avatar_file_size,
        :link => [:edit, self],
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

  def subscribe_url(plan_id=nil)
    "https://spreedly.com/#{SITE}/subscribers/#{id}/subscribe/#{plan_id || DEFAULT_PLAN_ID}/#{display_name.gsub(' ', '_')}?email=#{email}"
  end

  def edit_subscription_url
    "https://spreedly.com/#{SITE}/subscriber_accounts/#{spreedly_token}"
  end

  def refresh_from_spreedly
    subscriber = Subscriber.find(id)

    if subscriber
      self.paying = subscriber.active
      self.spreedly_token = subscriber.token
      # Subscription changes are not the time to deal with busted models
      save(:validate => false)
    else
      update_attribute(:paying, false)
    end
  end

  def send_welcome_email
    Notifier.welcome_email(self).deliver unless email.blank?
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

  def self.registrations_per_week
    ActiveRecord::Base.connection.execute(self
      .select("COUNT(*) AS count, date_trunc('week', created_at) as date")
      .group("date")
      .order("date ASC")
      .where("created_at > ?", 6.months.ago)
      .to_sql
    )
  end

  def self.cohort_analysis
    subquery = User.joins(:visits) \
      .select("users.id AS id,
        DATE_TRUNC('month', users.created_at) AS first_action,
        DATE_TRUNC('month', MAX(visits.created_at)) AS last_action") \
      .group("users.id, first_action") \
      .where("users.created_at >= DATE_TRUNC('month', CAST(? AS timestamp))", 12.months.ago)

    ActiveRecord::Base.connection.execute("
      SELECT
        COUNT(*) AS count,
        first_action,
        last_action
      FROM (#{subquery.to_sql}) AS temp
      GROUP BY first_action, last_action
      ORDER BY first_action ASC, last_action ASC
    ")
  end

  def self.contact_people_we_miss
    people_we_miss = User.subscribed.inactive.not_recently_contacted.limit(100)

    date = Time.now.strftime("%b %d %Y")

    people_we_miss.each do |person|
      Notifier.missed_you(person, date).deliver
    end
  end

  def self.contact_awesome_people
    awesome_people = User.subscribed.recent_sprites.group("users.id").count

    date = Time.now.strftime("%b %d %Y")

    awesome_people.each do |user_id, sprite_count|
      Notifier.you_are_awesome(user_id, sprite_count, date).deliver
    end
  end

  def self.gather_surveys
    people_to_survey = User.subscribed.recently_active.not_recently_surveyed

    people_to_survey.each do |person|
      Notifier.survey(person).deliver
    end
  end

  def sanitize_profile
    self.profile = Sanitize.clean(self.profile, :elements => ['a', 'img'],
      :attributes => {
        'a' => ['href', 'title'],
        'img' => ['src']
      },
      :protocols => {
        'a' => {'href' => ['http', 'https', 'mailto']},
        'img' => {'src' => ['http', 'data']}
      }
    )
  end

  def init_display_name
    if display_name.nil?
      if email
        if name = email.split('@').first
          name.gsub!(/[^A-Za-z0-9_-]/, '')
        end

        if name.blank?
          name = "Pixie-#{id}"
        end

        self.display_name = name
        save

        # Try some more names
        20.times do |i|
          if invalid?
            self.display_name = "#{name}-#{i + 2}"
          end

          save
        end
      end
    end
  end

  private

  def no_connected_sites?
    authenticated_with.length == 0
  end
end
