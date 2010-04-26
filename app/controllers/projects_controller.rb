class ProjectsController < ApplicationController
  resource_this :will_paginate => 10
  before_filter :new_feedback, :only => [ :index ]

  def index
    @projects.reverse! unless params[:last_id]

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
      #:include => [ :attachments ]
    }

    conditions = []
    bindings = []

    if params[:last_id].to_i > 0
      conditions << "projects.id < ?"
      bindings << params[:last_id]
    end

    if params[:first_id].to_i > 0
      conditions << "projects.id > ?"
      bindings << params[:first_id]
    end

    if params[:q] && params[:strict]
      conditions << 'title ilike ? or "desc" ilike ?'
      2.times { bindings << "%#{params[:q]}%" }
    end

    unless conditions.empty?
      options[:conditions] = [ '(' + conditions.join(') AND (') + ')' ]
      options[:conditions] << bindings
      options[:conditions].flatten!
    end

    p options

    options
  end
end
