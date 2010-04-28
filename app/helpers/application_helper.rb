module ApplicationHelper
  def want_category?(id)
    (!session[:categories] || session[:categories][id]) 
  end

  def want_source?(id)
    (!session[:sources] || session[:sources][id])
  end
end
