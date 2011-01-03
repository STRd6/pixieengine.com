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
    if app.lang = "coffeescript"
      add_default_libraries
      app.src = <<-eos
window.bullets = []

Square = (I) ->
  I ||= {}

  $.reverseMerge I,
    color: '#800'
    direction_change_timer: 0
    width: 25
    height: 25
    x: 50
    y: 50
    xVelocity: 5

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

  self = GameObject(I).extend

    before:
      update: ->
        I.direction_change_timer++

        if (I.direction_change_timer > 25)
          change_direction()

  self

Bullet = (I) ->
  I ||= {}

  $.reverseMerge I,
    color: '#CCC'
    radius: 3
    x: 50
    y: 50
    xVelocity: 10

  self = GameObject(I).extend

    draw: (canvas) ->
      canvas.fillColor I.color
      canvas.fillCircle I.x, I.y, I.radius

  self

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

Player = () ->
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
      Sound.play 65

    stop: ->
      I.xVelocity = 0

  self

circle = Circle()
square = Square()
player = Player()

Game.keydown 'left', -> player.move 'left'
Game.keyheld 'left', -> player.move 'left'
Game.keyup 'left', -> player.stop()

Game.keydown 'right', -> player.move 'right'
Game.keyheld 'right', -> player.move 'right'
Game.keyup 'right', -> player.stop()

Game.keydown 'space', -> player.shoot()

Game.update ->
  circle.update()
  square.update()
  player.update()

  window.bullets = window.bullets.select (bullet) ->
    bullet.update()

Game.draw (canvas) ->
  canvas.fill '#000'
  circle.draw canvas
  square.draw canvas
  player.draw canvas

  for bullet in window.bullets
    bullet.draw(canvas)

musicSrc = "http://jupiterman.net/project_strugglin/JM_Strugglin_01.mp3"

bgMusic = $(
  "<audio src='" +
  musicSrc + "' loop='loop' />"
).appendTo('body').get(0)
bgMusic.volume = 0.5
bgMusic.play()

      eos

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
    app.add_library(Library.find 1)
    app.add_library(Library.find 2)
    app.add_library(Library.find 7)
  end

  def collection
    @collection ||= App.order("id DESC")
  end
end
