attributes :id
attributes :display_name => :name

node :url do |model|
  url_for(model)
end

code :type do |model|
  model.class.name.downcase
end
