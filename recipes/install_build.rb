# Install dev dependencies
#
include_recipe 'apt::default'
include_recipe 'build-essential::default'

packages = value_for_platform_family(
  %w(rhel fedora suse) => %w(pcre-devel),
  %w(gentoo)      => [],
  %w(default)     => %w(libpcre3 libpcre3-dev)
)

packages.each do |pkg_name|
  package pkg_name
end

# Build nginx from source
#
instance = resources('nginx_resources_instance[default]')
source = resources('nginx_resources_source[nginx_default]')

nginx_resources_build 'default' do
  version     source.version
  source_dir  source.deploy_path
  root_dir    instance.root_dir
  sbin_path   instance.sbin_path
  conf_path   instance.conf_path
  service     instance.service
end
