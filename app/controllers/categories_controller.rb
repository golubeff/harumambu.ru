class CategoriesController < ApplicationController
  def create
    session[:categories] = {}
    params[:categories].each do |id, value|
      session[:categories][id.to_i] = true
    end
    redirect_to params[:redirect_to]
  end
end
