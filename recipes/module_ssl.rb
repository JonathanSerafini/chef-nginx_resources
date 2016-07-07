
if node['nginx_resources']['ssl']['use_native']
  # When use_native is enabled, install native operating system openssl
  # packages to compile against.
  #
  packages = value_for_platform_family(
    %w(rhel fedora suse) => %w(openssl-devel),
    %w(gentoo) => [],
    %w(default) => %w(libssl-dev)
  )

  packages.each do |name|
    package name
  end
else
  # When use_native is disabled, install openssl source against which we will
  # staticly compile nginx.
  #
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

# SSL configuration directives
#
nginx_resources_config 'ssl' do
  category  'config'
  source    'config/generic.conf.erb'
  configs node['nginx_resources']['ssl']['config']
end

# Map to create the x_forwarded_https variable, which may be used when
# proxying to ensure that backend servers know SSL was terminated on the
# proxy.
#
nginx_resources_config 'ssl_map' do
  category 'config'
  source   'config/map.conf.erb'
  configs  'from' => '$scheme',
           'to' => '$x_forwarded_https',
           'mappings' => {
             'http' => false,
             'https' => true
           }
end

# Optionally generate a dhparam.pem hash file to provide better security with
# strong certificates.
#
bash 'generate_dhparam' do
  code <<-EOH
    openssl dhparam -dsaparam -out /etc/ssl/dhparam.pem 4096
  EOH
  not_if do
    ::File.exist?('/etc/ssl/dhparam.pem')
  end
  only_if do
    node['nginx_resources']['ssl']['generate_dhparam']
  end
end

# Enable the builtin SSL module
#
node.default['nginx_resources']['source'].tap do |source_attr|
  source_attr['builtin_modules']['http_ssl_module'] = true
end
