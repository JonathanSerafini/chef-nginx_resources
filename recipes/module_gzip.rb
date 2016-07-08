
packages = value_for_platform_family(
  %w(default) => %w(zlib1g-dev)
)

packages.each do |pkg_name|
  package pkg_name
end

nginx_resources_config 'gzip' do
  category  'config'
  source    'config/generic.conf.erb'
  configs node['nginx_resources']['gzip']['config']
end
