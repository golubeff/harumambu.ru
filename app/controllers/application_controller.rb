class ApplicationController < ActionController::Base
  protect_from_forgery

  def index
  end

  def settings
    if params[:value] && !params[:value].empty?
      session[params[:key]] = params[:value]
    else
      session.delete(params[:key])
    end
    render :nothing => true
  end

  def redirect
    redirect_to params[:href]
  end

end
