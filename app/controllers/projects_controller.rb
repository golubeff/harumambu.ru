class ProjectsController < ApplicationController
  resource_this :will_paginate => 10
  before_filter :new_feedback, :only => [ :index ]

  def index
    @projects.reverse!

    respond_to do |format|
      format.js { render :layout => false }
      format.html
    end
  end

  protected
  def new_feedback
    @feedback = Feedback.new
  end

  def finder_options
    options = { 
      :include => [ :attachments ]
    }

    options[:conditions] = [ "projects.id < ?", params[:last_id] ] if params[:last_id]
    options[:conditions] = [ "projects.id > ?", params[:first_id] ] if params[:first_id]

    options
  end
end
