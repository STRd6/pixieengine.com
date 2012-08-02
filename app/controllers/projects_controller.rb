class ProjectsController < ApplicationController
  respond_to :html, :json

  PUBLIC_ACTIONS = [:index, :show, :hook, :info, :ide, :github_integration, :fullscreen, :demo, :arcade, :landing1, :widget]
  before_filter :require_user, :except => PUBLIC_ACTIONS
  before_filter :require_access, :except => PUBLIC_ACTIONS + [:new, :create, :fork, :feature, :add_to_arcade, :add_to_tutorial]
  before_filter :require_owner_or_admin, :only => [:destroy, :add_member, :remove_member]
  before_filter :require_admin, :only => [:feature, :add_to_arcade, :add_to_tutorial]

  before_filter :count_view, :only => [:fullscreen]

  before_filter :redirect_to_user_page_if_logged_in, :only => :info

  def new
    @modify_remote_origin = true

    if current_user.projects.size > 0 && !current_user.paying
      flash[:notice] = "You have reached the limit of free projects. Please subscribe to access more."
      redirect_to subscribe_path
    else
      @project = Project.new
    end
  end

  def edit
  end

  def add_member
    user = User.find params[:user_id]

    if project.user != user && !Membership.find_by_group_id_and_user_id(project.id, user.id)
      Membership.create :group => project, :user => user
    end

    render :nothing => true
  end

  def remove_member
    user = User.find params[:user_id]

    if Membership.find_by_group_id_and_user_id(project.id, user.id)
      Membership.find_by_group_id_and_user_id(project.id, user.id).destroy
    end

    render :nothing => true
  end

  def find_member_users
    term = params[:term]

    if term
      like = "%#{term}%".downcase
      users = User.where("lower(display_name) like ?", like)
    else
      users = User.all
    end

    list = users.map do |user|
      { :id => user.id, :label => user.display_name, :name => user.display_name, :icon => user.avatar(:tiny) }
    end

    render :json => list
  end

  def index
    load_projects

    respond_to do |format|
      format.html { }
      format.json { render :json => @projects_data }
    end
  end

  def load_projects
    @projects = filter_results

    if params[:search]
      projects_list = @projects.order("id DESC").search(params[:search]).paginate(:page => params[:page], :per_page => per_page)
    else
      projects_list = @projects.order("id DESC").paginate(:page => params[:page], :per_page => per_page)
    end

    current_page = projects_list.current_page
    total = projects_list.total_pages
    current_user_id = current_user ? current_user.id : nil

    @projects_data = {
      :owner_id => nil,
      :current_user_id => current_user_id,
      :page => current_page,
      :per_page => per_page,
      :total => total,
      :models => projects_list
    }
  end

  def destroy
    project_owner = project.user
    project.destroy

    respond_to do |format|
      format.html do
        flash[:notice] = "Project has been deleted"
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
    project.update_attribute(:arcade, !params[:remove])

    respond_to do |format|
      format.json do
        render :json => {
          :status => "ok"
        }
      end
    end
  end

  def add_to_tutorial
    project.update_attribute(:tutorial, !params[:remove])

    respond_to do |format|
      format.json do
        render :json => {
          :status => "ok"
        }
      end
    end
  end

  def feature
    project.update_attribute(:featured, !params[:remove])

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
    @hide_feedback = true
  end

  def update
    project.update_attributes(params[:project])

    respond_with(project)
  end

  def create
    @project = Project.new(params[:project])
    @project.user = current_user

    if @project.save
      track_event('create_project')

      respond_with([:ide, @project])
    else
      track_event('create_project_error')

      respond_with @project.user, @project
    end
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
    respond_with project
  end

  def ide
    @hide_feedback = true

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

  def remove_file
    message = params[:message].presence

    project.remove_file(params[:path], current_user, message)

    respond_to do |format|
      format.json do
        render :json => {
          :status => "ok"
        }
      end
    end
  end

  def rename_file
    message = params[:message].presence

    project.rename_file(params[:path], params[:new_path], current_user, message)

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
    doc = params[:generate_docs].presence

    project.save_file(params[:path], contents, current_user, message, doc)

    project.touch if params[:touch]

    respond_to do |format|
      format.json do
        render :json => {
          :status => "ok"
        }
      end
    end
  end

  def filter_results
    @projects ||= if params[:user_id].present?
      Project.for_user(User.find_by_display_name!(params[:user_id]))
    elsif (filter == "own" || filter == "my_projects")
      if current_user
        Project.for_user(current_user)
      else
        Project
      end
    elsif filter == "for_user"
      Project.for_user(User.find(params[:user_id]))
    else
      if filters.include? filter
        # Always use a whitelist before calling send
        Project.send(filter)
      else
        Project
      end
    end
  end

  def filters
    ["featured", "own", "all", "my_projects", "none", "for_user", "recently_edited", "tutorials", "arcade"]
  end

  def gallery_filters
    filters = [
      ["Arcade", :arcade],
      ["Featured", :featured],
      ["Tutorials", :tutorials],
      ["Recently Edited", :recently_edited],
      ["All", :all]
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
    return @object if defined?(@object)

    if params[:user_id].present?
      return @project = @object = User.find_by_display_name!(params[:user_id]).projects.find_by_title!(params[:id])
    end

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
    if params[:per_page].blank?
      24
    else
      params[:per_page].to_i
    end
  end

  def redirect_to_user_page_if_logged_in
    redirect_to current_user if current_user
  end
end
