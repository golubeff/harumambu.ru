class SourcesController < ApplicationController
  def create
    session[:sources] = {}
    if params[:sources]
      params[:sources].each do |id, value|
        session[:sources][id] = true
      end
    end
    redirect_to params[:redirect_to]
  end
end
