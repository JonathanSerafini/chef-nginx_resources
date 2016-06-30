
if node['nginx_resources']['ssl']['use_native']
  packages = value_for_platform_family(
    %w(rhel fedora suse) => %w(openssl-devel),
    %w(gentoo) => [],
    %w(default) => %w(libssl-dev)
  )

  packages.each do |name|
    package name
  end
else
  source = nginx_resources_source 'module_ssl' do
    version   node['nginx_resources']['ssl']['module']['version']
    checksum  node['nginx_resources']['ssl']['module']['checksum']
    source    node['nginx_resources']['ssl']['module']['source']
  end

  node.default['nginx_resources']['source'].tap do |source_attr|
    flag = "--with-openssl=#{source.deploy_path}"
    source_attr['additional_configure_flags'] << flag
  end
end

config = nginx_resources_config 'ssl' do
  category  'config'
  source    'config/generic.conf.erb'
  configs    node['nginx_resources']['ssl']['config']
end

bash "generate_dhparam" do
  code <<-EOH
    openssl dhparam -dsaparam -out /etc/ssl/dhparam.pem 4096
  EOH
  not_if do
    ::File.exists?("/etc/ssl/dhparam.pem")
  end
  only_if do
    node['nginx_resources']['ssl']['generate_dhparam']
  end
end

node.default['nginx_resources']['source'].tap do |source_attr|
  source_attr['builtin_modules']['http_ssl_module'] = true
end

