class ApplicationController < ActionController::Base
  protect_from_forgery

  def index
  end

  def redirect
    redirect_to params[:href]
  end

end
