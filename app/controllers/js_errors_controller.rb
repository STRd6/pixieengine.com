class JsErrorsController < ApplicationController
  respond_to :html, :json

  def create
    js_error_params = params[:js_error].merge(
      :user => current_user,
      :session_id => request.session_options[:id]
    )

    js_error = JsError.create(js_error_params)

    respond_with(js_error)
  end

  def index
    respond_with(js_errors) do |format|
      format.json { render :json }
    end
  end

  private

  helper_method :js_errors
  def js_errors
    @collection ||= JsError.order("id DESC").paginate(:page => params[:page], :per_page => per_page)
  end
end
