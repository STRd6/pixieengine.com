class ProjectsController < ApplicationController
  respond_to :html, :json

  PUBLIC_ACTIONS = [:index, :show, :hook, :info, :ide, :github_integration, :fullscreen, :demo, :arcade, :landing1]
  before_filter :require_user, :except => PUBLIC_ACTIONS
  before_filter :require_access, :except => PUBLIC_ACTIONS + [:new, :create, :fork, :feature, :add_to_arcade, :add_to_tutorial]
  before_filter :require_owner_or_admin, :only => :destroy
  before_filter :require_admin, :only => [:feature, :add_to_arcade, :add_to_tutorial]

  before_filter :filter_results, :only => [:index]

  before_filter :count_view, :only => [:fullscreen]

  before_filter :hide_dock, :only => [:github_integration, :info, :fullscreen]

  before_filter :redirect_to_user_page_if_logged_in, :only => :info

  def new
    if current_user.projects.size > 0 && !current_user.paying
      flash[:notice] = "You have reached the limit of free projects. Please subscribe to access more."
      redirect_to subscribe_path
    else
      @project = Project.new
    end
  end

  def edit
  end

  def index
  end

  def destroy
    project_owner = project.user
    project.destroy

    respond_to do |format|
      format.html do
        flash[:notice] = "Project has been archived"
        redirect_to project_owner
      end
      format.json do
        render :json => {
          :status => "ok"
        }
      end
    end
  end

  def debug
    render :layout => "widget"
  end

  def add_to_arcade
    project.update_attribute(:arcade, true)

    respond_to do |format|
      format.json do
        render :json => {
          :status => "ok"
        }
      end
    end
  end

  def add_to_tutorial
    project.update_attribute(:tutorial, true)

    respond_to do |format|
      format.json do
        render :json => {
          :status => "ok"
        }
      end
    end
  end

  def feature
    project.update_attribute(:featured, true)

    respond_to do |format|
      format.html do
        redirect_to :project
      end

      format.json do
        render :json => {
          :status => "ok"
        }
      end
    end
  end

  def fullscreen
    @has_reg_popup = true
  end

  def widget
    respond_to do |format|
      format.html { render :layout => "widget" }
      format.js { render :layout => nil }
    end
  end

  def download
    if params[:chrome]
      if current_user.paying
        project.prepare_for_web_store
      end
    end

    project.zip_for_export
    send_file project.zip_path, :type=>"application/zip"
  end

  def info
    @title = "PixieEngine - Create Games"
    @hide_chat = true
    @hide_dock = true
    @theme = :light
  end

  def update
    project.update_attributes(params[:project])

    respond_with(project)
  end

  def create
    @project = Project.new(params[:project])
    @project.user = current_user

    @project.save

    respond_with([:ide, @project])
  end

  def fork
    respond_with Project.create(
      :parent => project,
      :title => "#{project.title} (#{current_user.display_name}'s Fork)",
      :description => project.description,
      :user => current_user
    )
  end

  def hook
    push = HashWithIndifferentAccess.new(JSON.parse(params[:payload]))

    url = push[:repository][:url]

    Project.with_url(url).each(&:git_pull)

    render :text => "ok"
  end

  def show
  end

  def ide
    respond_with(project) do |format|
      format.html do
        @has_reg_popup = true
        render :layout => "ide"
      end
    end
  end

  def tag_version
    tag = params[:tag]
    message = params[:message].blank? ? "Tagged in browser at pixie.strd6.com" : params[:message]

    project.tag_version(tag, message)

    respond_to do |format|
      format.json do
        render :json => {
          :status => "ok"
        }
      end
    end
  end

  def generate_docs
    project.generate_docs

    respond_to do |format|
      format.json do
        render :json => {
          :status => "ok"
        }
      end
    end
  end

  def update_libs
    project.update_libs

    respond_to do |format|
      format.json do
        render :json => {
          :status => "ok"
        }
      end
    end
  end

  def save_file
    if params[:contents_base64]
      contents = Base64.decode64(params[:contents_base64])
    else
      contents = params[:contents]
    end

    message = params[:message].presence

    project.save_file(params[:path], contents, message)

    project.touch if params[:touch]

    respond_to do |format|
      format.json do
        render :json => {
          :status => "ok"
        }
      end
    end
  end

  def remove_file
    message = params[:message].presence

    project.remove_file(params[:path], message)

    respond_to do |format|
      format.json do
        render :json => {
          :status => "ok"
        }
      end
    end
  end

  def filter_results
    @projects ||= if current_user
      if filter == "own"
        Project.for_user(current_user)
      elsif filter == "for_user"
        Project.for_user(User.find(params[:user_id]))
      else
        Project.send(filter)
      end
    else
      Project
    end.order("id DESC").paginate(:page => params[:page], :per_page => per_page)
  end

  def filters
    ["featured", "own", "none", "for_user", "tutorial", "arcade"]
  end

  def gallery_filters
    filters = [
      ["Arcade", :arcade],
      ["Featured", :featured],
      ["Tutorials", :tutorial],
      ["All", :none]
    ]

    filters.push ["My Projects", :own] if current_user

    filters
  end
  helper_method :gallery_filters

  def demo?
    params[:id] == "demo"
  end
  helper_method :demo?

  def tutorial?
    project.tutorial?
  end
  helper_method :tutorial?

  private
  def object
    @project ||= if demo?
      if current_user
        # Use the source demo project if this one is likely to be too new
        if current_user.demo_project.created_at < 2.minutes.ago
          current_user.demo_project
        else
          Project.find Project::DEMO_ID
        end
      else
        Project.find Project::DEMO_ID
      end
    else
      Project.find params[:id]
    end
  end
  helper_method :object

  def project
    object
  end
  helper_method :project

  def projects
    @projects ||= Project.all
  end
  helper_method :projects

  def default_project_config
    Project::DEFAULT_CONFIG.merge(:name => project.title)
  end
  helper_method :default_project_config

  def per_page
    24
  end

  def redirect_to_user_page_if_logged_in
    redirect_to current_user if current_user
  end
end
