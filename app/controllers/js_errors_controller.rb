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
end
