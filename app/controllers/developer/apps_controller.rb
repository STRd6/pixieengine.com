class Developer::AppsController < DeveloperController
  resource_controller
  actions :all, :except => [:destroy]

  before_filter :require_user, :only => [:fork_post, :new, :create]
  before_filter :require_access, :only => [:edit, :update, :add_library, :remove_library]
  before_filter :require_owner, :only => [:add_user]

  respond_to :html, :xml, :json

  create.wants.html { redirect_to ide_developer_app_path(app) }

  create.before do
    app.user = current_user
    if app.lang == "coffeescript"
      add_default_libraries
      heredoc = <<-eos
window.bullets = [] #initialize an empty global array to store bullets

###
In this application all the classes are included in the same file
for simplicity. Typically, you would add a library for your game and save
each class as a script in that library.
###

###
The Square class is part of the Pixie default app. It is used to demonstrate
how to draw a rectangle to screen and how you can make an object move linearly
along the x and y axes.

@name Square
@constructor

@param {Object} I Instance variables
###

Square = (I) ->
  I ||= {}

  ###
  I is a hash that stores all the instance variables of the class.
  $.reverseMerge adds the properties to the hash if I currently does
  not have that property. You can think of the call
  to $.reverseMerge as setting up default values for I.
  ###

  $.reverseMerge I,
    color: '#800'
    direction_change_timer: 0
    width: 25
    height: 25
    x: 50
    y: 50
    xVelocity: 5

  ###
  This is a private method. It is used to tell the square
  when and how to change direction.
  ###

  change_direction = ->
    if (I.xVelocity == 5)
      I.xVelocity = 0
      I.yVelocity = 5
    else if (I.yVelocity == 5)
      I.yVelocity = 0
      I.xVelocity = -5
    else if (I.xVelocity == -5)
      I.xVelocity = 0
      I.yVelocity = -5
    else if (I.yVelocity == -5)
      I.yVelocity = 0
      I.xVelocity = 5

    I.direction_change_timer = 0

  ###
  Here we define our public methods. All methods declared within the
  self object are visible to clients of the class.

  We extend the functionality of GameObject in order
  to get some basic useful methods.

  @see GameObject
  ###

  self = GameObject(I).extend

    ###
    Since GameObject already provides an update method, we want to execute our
    update code before or after GameObject#update. If we don't use the before
    filter, we will overwrite GameObject#update.

    @see GameObject#update
    ###

    before:
      update: ->
        I.direction_change_timer++

        if (I.direction_change_timer > 25)
          change_direction()

  self

###
The Bullet class is part of the Pixie default app. It is used
to demonstrate how to draw a circular projectile to screen.

@name Bullet
@constructor

@param {Object} I Instance variables
###

Bullet = (I) ->
  I ||= {}

  $.reverseMerge I,
    color: '#CCC'
    radius: 3
    x: 50
    y: 50
    xVelocity: 10

  self = GameObject(I).extend

    ###
    Here we have overridden GameObject#draw since we want to draw a circle
    instead of the rectangle that is drawn by GameObject#draw
    ###

    draw: (canvas) ->
      canvas.fillColor I.color
      canvas.fillCircle I.x, I.y, I.radius

  self

###
The Circle class is part of the Pixie default app. It is used to demonstrate
how to draw a circle to screen and how to make an object move radially.

@name Circle
@constructor

@param {Object} I Instance variables
###

Circle = (I) ->
  I ||= {}

  $.reverseMerge I,
    color: '#080'
    radius: 15
    theta: -Math.PI
    x: 50
    y: 50
    velocity: 50

  self = GameObject(I).extend

    before:
      update: ->
        I.theta += Math.PI / 32
        I.x = (Math.cos(I.theta) * I.velocity) + 350
        I.y = (Math.sin(I.theta) * I.velocity) + 120

    draw: (canvas) ->
      canvas.fillColor I.color
      canvas.fillCircle I.x, I.y, I.radius

  self

###
The Player class is part of the Pixie default app. It is used to demonstrate
how to draw text to screen and how to manage collections of game objects.

@name Player
@constructor

@param {Object} I Instance variables
###

Player = (I) ->
  I ||= {}

  $.reverseMerge I,
    color: '#FFF'
    x: 30
    y: 280
    width: 20
    height: 20

  message = (canvas) ->
    canvas.fillColor('#FFF')
    canvas.fillText("You can move me.", I.x, I.y - 18)
    canvas.fillText("Press left or right.", I.x, I.y - 5)

  self = GameObject(I).extend

    before:
      draw: (canvas) ->
        if (I.xVelocity == 0)
          message(canvas)

    after:
      update: ->
        I.x = I.x.clamp(0, 480 - I.width)

    move: (direction) ->
      if (direction == 'left')
        I.xVelocity = -5

      if (direction == 'right')
        I.xVelocity = 5

    shoot: ->
      window.bullets.push(Bullet(
        x: I.x,
        y: I.y + I.height / 2
      ))
      Sound.play 65 #Pew, Pew, Pew!

    stop: -> I.xVelocity = 0

  self

#Here we create instances of each of the classes we defined above.

circle = Circle()
square = Square()
player = Player()

###
This is how to manage keyboard input in Pixie. The keydown event is fired if
the key was just pressed. The keyheld event is fired if the key is currently down
and was previously down. They keyup event is fired if the key was previously down
and is currently not pressed.
###

Game.keydown 'left', -> player.move 'left'
Game.keyheld 'left', -> player.move 'left'
Game.keyup 'left', -> player.stop()

Game.keydown 'right', -> player.move 'right'
Game.keyheld 'right', -> player.move 'right'
Game.keyup 'right', -> player.stop()

Game.keydown 'space', -> player.shoot()


#Anything within Game#update is called each time through the game's loop

Game.update ->
  circle.update()
  square.update()
  player.update()

  ###
  This purges the inactive bullets.

  Bullet#update returns true if the object is active and false otherwise.
  Array#select makes a new array from the true values of Bullet#update
  ###

  window.bullets = window.bullets.select (bullet) ->
    bullet.update()

###
Game#draw provides a reference to the canvas in order to draw
each time through the game's loop.
###

Game.draw (canvas) ->
  canvas.fill '#000' #clear the screen each frame
  circle.draw canvas
  square.draw canvas
  player.draw canvas

  for bullet in window.bullets
    bullet.draw(canvas)


#This is how to add background music to your game.

musicSrc = "http://jupiterman.net/project_strugglin/JM_Strugglin_01.mp3"

bgMusic = $(
  "<audio src='" + musicSrc + "' loop='loop' />"
).appendTo('body').get(0)

bgMusic.volume = 0.5
bgMusic.play()

      eos

      app.src = heredoc

    end
  end

  def create_app_sprite
    if has_access?
      app_sprite_data = params[:app_sprite]
      app_sprite_data[:sprite] = Sprite.new(app_sprite_data[:sprite].merge(:user => current_user))

      if params[:app_sprite_id]
        app_sprite = app.app_sprites.find params[:app_sprite_id]
      end

      if app_sprite
        app_sprite.update_attributes app_sprite_data
      else
        app_sprite = app.app_sprites.create app_sprite_data
      end

      respond_to do |format|
        format.json {render :json => app_sprite}
      end
    else
      render :json => {
        :status => "error",
        :message => "You do not have access to this app"
      }
    end
  end

  def import_app_sprites
    if has_access?
      sprite_data = params[:sprite_data]

      app_sprites = []

      sprite_data.each_value do |sprite|
        (app_sprite = AppSprite.create(
          :app_id => sprite["app_id"],
          :sprite_id => sprite["app_sprite_id"],
          :name => (sprite["app_sprite_name"] == "undefined") ? "Sprite #{sprite["app_sprite_id"]}" : sprite["app_sprite_name"]
        )
        app_sprites << {
          :id => app_sprite.id,
          :height => app_sprite.height,
          :width => app_sprite.width,
          :name => app_sprite.name,
          :cssImageUrl => "url(#{app_sprite.data_url})"
        }) unless AppSprite.find_by_app_id_and_sprite_id(app.id, sprite["app_sprite_id"])
      end

      respond_to do |format|
        format.json { render :json => app_sprites }
      end

    else
      render :json => {
        :status => "error",
        :message => "You do not have access to this app"
      }
    end
  end

  def import_app_sounds
    if has_access?
      sound_data = params[:sound_data]

      app_sounds = []

      sound_data.each_value do |sound|
        (app_sound = AppSound.create(
          :app_id => sound["app_id"],
          :sound_id => sound["app_sound_id"],
          :name => (sound["app_sound_name"] == "undefined") ? "Sound #{sound["app_sound_id"]}" : sound["app_sound_name"]
        )
        app_sounds << {
          :id => app_sound.id,
          :name => app_sound.name,
          :cssImageUrl => "url(/images/icons/sound)"
        }) unless AppSound.find_by_app_id_and_sound_id(app.id, sound["app_sound_id"])
      end

      respond_to do |format|
        format.json { render :json => app_sounds }
      end

    else
      render :json => {
        :status => "error",
        :message => "You do not have access to this app"
      }
    end
  end

  def set_app_data
    if has_access?
      app_datum_data = params[:app_datum]

      if params[:app_datum_id]
        datum = app.app_data.find params[:app_datum_id]
      end

      if datum
        datum.update_attributes app_datum_data
      else
        app_datum = app.app_data.create app_datum_data
      end

      respond_to do |format|
        format.json {render :json => app_datum}
      end
    else
      render :json => {
        :status => "error",
        :message => "You do not have access to this app"
      }
    end
  end

  def fork_post
    fork = App.create(
      :parent => app,
      :title => "#{app.title} (#{current_user.display_name}'s Fork)",
      :description => app.description,
      :html => app.html,
      :libraries => app.libraries,
      :width => app.width,
      :height => app.height,
      :code => app.code,
      :test => app.test,
      :user => current_user
    )

    redirect_to edit_developer_app_path(fork)
  end

  def add_user
    AppMember.create :app => app, :user => User.find(params[:user_id])

    flash[:notice] = "Added user id #{params[:user_id]} to app"

    redirect_to :back
  end

  def ide
    @user_sprites = (current_user) ? current_user.sprites : []
    @user_sounds = (current_user) ? Sound.find_all_by_user_id(current_user) : []
    render :layout => "ide"
  end

  def load
    @app = App.new(
      :parent => app,
      :title => app.title,
      :description => app.description,
      :html => app.html,
      :code => app.code,
      :test => app.test
    )
  end

  def mobile
    render :layout => "mobile"
  end

  def fullscreen
    render :layout => "fullscreen"
  end

  def widget
    respond_to do |format|
      format.html {render :layout => "widget"}
      format.js {render :layout => nil}
    end
  end

  def add_library
    library = Library.find(params[:library_id])
    app.add_library(library)

    respond_to do |format|
      format.json do
        render :json => {
          :status => "ok",
          :library => {
            :id => library.id,
            :scripts => library.scripts.map {|script| {:title => script.title, :id => script.id, :lang => script.lang, :code => script.code, :src => script.src} },
            :title => library.title
          }
        }
      end
      format.html do
        flash[:notice] = "Library added"
        redirect_to :back
      end
    end
  end

  def remove_library
    app.remove_library(Library.find(params[:library_id]))

    respond_to do |format|
      format.json { render :json => {:status => "ok"} }
      format.html do
        flash[:notice] = "Library removed"
        redirect_to :back
      end
    end
  end

  def publish
    app.publish

    respond_to do |format|
      format.json { render :json => {:status => "ok"} }
      format.html do
        flash[:notice] = "Published Latest Version"
        redirect_to :back
      end
    end
  end

  private
  def app
    object
  end
  helper_method :app

  private
  def apps
    collection
  end
  helper_method :apps

  private
  def add_default_libraries
    default_library = Library.create(:user_id => current_user.id, :title => app.title, :description => "Scripts for #{app.title} belong here")

    app.add_library(Library.find 1)
    app.add_library(Library.find 2)
    app.add_library(Library.find 7)
    app.add_library(default_library)
  end

  def collection
    @collection ||= App.order("id DESC")
  end
end
