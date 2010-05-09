class ProjectsController < ApplicationController
  resource_this :will_paginate => 10
  before_filter :new_feedback, :only => [ :index ]

  def index
    @projects.reverse! unless params[:last_id]

    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end

  protected
  def new_feedback
    @feedback = Feedback.new
  end

  def finder_options
    options = { 
      #:include => [ :attachments ]
      #:include => :category
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
      session[:first_id] = params[:first_id]
    end

    if params[:q] && params[:strict].to_i > 0
      conditions << 'title ilike ? or "desc" ilike ?'
      2.times { bindings << "%#{params[:q]}%" }
    end

    if session[:categories] && session[:categories].keys.size > 0
      conditions << "category_id in (#{session[:categories].keys.map{'?'}.join(',')})"
      session[:categories].keys.each { |k| bindings << k  }
    end

    if session[:sources] && session[:sources].keys.size > 0
      conditions << "klass in (#{session[:sources].keys.map{'?'}.join(',')})"
      session[:sources].keys.each { |k| bindings << k }
    end

    unless conditions.empty?
      options[:conditions] = [ '(' + conditions.join(') AND (') + ')' ]
      options[:conditions] << bindings
      options[:conditions].flatten!
    end

    options
  end
end
