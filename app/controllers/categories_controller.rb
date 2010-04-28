class CategoriesController < ApplicationController
  def create
    session[:categories] = {}
    if params[:categories]
      params[:categories].each do |id, value|
        session[:categories][id.to_i] = true
      end
    end
    redirect_to params[:redirect_to]
  end
end
