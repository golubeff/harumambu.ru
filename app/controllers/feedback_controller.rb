class FeedbackController < ApplicationController
  def create
    Notifier.feedback(params[:feedback_message]).deliver
    render :layout => false
  end
end
