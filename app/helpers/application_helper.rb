module ApplicationHelper
  def project_json(project)
    "{ 
      'id' : #{ project.id }, 
      'budjet' : '#{project.budjet_with_currency }', 
      'title' : '#{project.title }', 
      'desc' : '#{project.attributes['desc'] }',
      'created_at' : '#{l project.created_at }',
      'url' : '#{ project.url }'
    }"
  end
end
