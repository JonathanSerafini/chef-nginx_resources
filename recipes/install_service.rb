# Deploy the nginx service
#
instance = resources('nginx_resources_instance[default]')
init_style = node['nginx_resources']['service']['init_style']

service 'nginx' do
  case init_style
  when 'upstart'
    provider Chef::Provider::Service::Upstart
  else raise NotImplementedError.new('the nginx init_style is not supported')
  end

  supports :status => true, :restart => true, :reload => true

  action  case node['nginx_resources']['service']['should_start']
          when true then :start
          else :nothing
          end

  only_if do
    node['nginx_resources']['service']['managed']
  end
end
