resource_name :nginx_resources_instance

property :user,
  kind_of: String,
  default: lazy { |r| node['nginx_resources']['user'] }

property :group,
  kind_of: String,
  default: lazy { |r| node['nginx_resources']['group'] }

property :root_dir,
  kind_of: String,
  default: lazy { |r| 
    "#{node['nginx_resources']['root_dir']}/nginx-#{r.name}" 
  }

property :conf_dir,
  kind_of: String,
  default: lazy { |r| "#{r.root_dir}/etc" }

property :conf_path,
  kind_of: String,
  default: lazy { |r| "#{r.conf_dir}/nginx.conf" }

property :sbin_dir,
  kind_of: String,
  default: lazy { |r| "#{r.root_dir}/sbin" }

property :sbin_path,
  kind_of: String,
  default: lazy { |r| "#{r.sbin_dir}/nginx" }

property :pid_dir,
  kind_of: String,
  default: lazy { |r| node['nginx_resources']['pid_dir'] }

property :pid_path,
  kind_of: String,
  default: lazy { |r| "#{r.pid_dir}/nginx-#{r.name}" }

property :spool_dir,
  kind_of: String,
  default: lazy { |r| node['nginx_resources']['spool_dir'] }

property :log_dir,
  kind_of: String,
  default: lazy { |r| node['nginx_resources']['log_dir'] }

property :log_group,
	kind_of: String,
  default: lazy { |r| node['nginx_resources']['log_group'] }

property :log_dir_perm,
  kind_of: String,
  coerce: proc { |v| v.to_s },
  default: lazy { |r| node['nginx_resources']['log_dir_perm'] }

property :service,
  kind_of: String,
  default: lazy { |r| "service[nginx-#{r.name}]" }

property :source,
  kind_of: String,
  default: "nginx.conf.erb"

property :cookbook,
  kind_of: String,
  default: "nginx_resources"

property :variables,
  kind_of: Hash,
  coerce: proc { |v| 
    case v
    when Chef::Node::ImmutableMash then v.to_hash
    else v
    end
  },
  default: Hash.new

property :configs,
  kind_of: Hash,
  coerce: proc { |v| 
    case v
    when Chef::Node::ImmutableMash then v.to_hash
    else v
    end
  }

action :install do
  %w(root_dir conf_dir sbin_dir pid_dir).each do |key|
    directory new_resource.send(key) do
      owner 'root'
      group node['root_group']
      mode  0755
      recursive true
    end
  end

  directory new_resource.log_dir do
    owner new_resource.user
    group new_resource.log_group
    mode  new_resource.log_dir_perm
    recursive true
  end

  directory new_resource.spool_dir do
    owner new_resource.user
    group node['root_group']
    mode  0750
    recursive true
  end

  conf_subdirs.each do |name|
    directory ::File.join(new_resource.conf_dir, name) do
      owner 'root'
      group node['root_group']
      mode  0755
    end
  end

  template new_resource.conf_path do
    source new_resource.source
    cookbook new_resource.cookbook
    variables template_variables

    helper(:on_off) do |bool|
      bool ? "on" : "off"
    end

    notifies :restart, new_resource.service, :delayed
  end
end

action_class do
  # chef/chef#4537
  def whyrun_supported?
    true
  end

  def conf_subdirs
    %w(
      conf.d
      module.d
      include.d
      site.d
    )
  end

  def template_variables
    variables = {
      'name'      => new_resource.name,
      'user'      => new_resource.user,
      'group'     => new_resource.group,
      'pid'       => new_resource.pid_path,
      'pid_dir'   => new_resource.pid_dir,
      'log_dir'   => new_resource.log_dir,
      'conf_dir'  => new_resource.conf_dir,
      'spool_dir' => new_resource.spool_dir,
      'configs'   => new_resource.configs
    }
    variables.merge!(new_resource.variables)
    variables
  end
end

