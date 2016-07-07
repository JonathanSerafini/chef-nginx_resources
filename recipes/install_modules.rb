# Include additional recipes, modules, overrides, etc...
#
node['nginx_resources']['source']['include_recipes'].each do |recipe, bool|
  next unless bool
  include_recipe recipe
end
