module ApplicationHelper
  def want_category?(id)
    (!session[:categories] || session[:categories][id]) 
  end
end
