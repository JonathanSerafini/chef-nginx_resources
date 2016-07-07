# Instance resource which represents the directory structure of an nginx
# deployment. Further resources such as Config, Build and Site will depend
# on this.
#
resource_name :nginx_resources_instance

# The user name under which the service runs
# @since 0.1.0
property :user,
  kind_of: String,
  default: lazy { |_r| node['nginx_resources']['user'] }

# The group name under which the service runs
# @since 0.1.0
property :group,
  kind_of: String,
  default: lazy { |_r| node['nginx_resources']['group'] }

# The root directory under which subdirs and files will be created
# @since 0.1.0
property :root_dir,
  kind_of: String,
  default: lazy { |r|
    "#{node['nginx_resources']['root_dir']}/nginx-#{r.name}"
  }

# The configuration directory
# @since 0.1.0
property :conf_dir,
  kind_of: String,
  default: lazy { |r| "#{r.root_dir}/etc" }

# The main configuration file path
# @since 0.1.0
property :conf_path,
  kind_of: String,
  default: lazy { |r| "#{r.conf_dir}/nginx.conf" }

# The binary directory
# @since 0.1.0
property :sbin_dir,
  kind_of: String,
  default: lazy { |r| "#{r.root_dir}/sbin" }

# The binary file path
# @since 0.1.0
property :sbin_path,
  kind_of: String,
  default: lazy { |r| "#{r.sbin_dir}/nginx" }

# The pid directory
# @since 0.1.0
property :pid_dir,
  kind_of: String,
  default: lazy { |_r| node['nginx_resources']['pid_dir'] }

# The pid file path
# @since 0.1.0
property :pid_path,
  kind_of: String,
  default: lazy { |r| "#{r.pid_dir}/nginx-#{r.name}" }

# The temporary file directory
# @since 0.1.0
property :spool_dir,
  kind_of: String,
  default: lazy { |_r| node['nginx_resources']['spool_dir'] }

# The logging directory
# @since 0.1.0
property :log_dir,
  kind_of: String,
  default: lazy { |_r| node['nginx_resources']['log_dir'] }

# The group owning the log files (ex.: admin under ubuntu)
# @since 0.1.0
property :log_group,
  kind_of: String,
  default: lazy { node['nginx_resources']['log_group'] }

# The permissions of the logging directory
# @since 0.1.0
property :log_dir_perm,
  kind_of: String,
  coerce: proc { |v| v.to_s },
  default: lazy { node['nginx_resources']['log_dir_perm'] }

# The name of the service resource (so that dependant resources can notify)
# @since 0.1.0
property :service,
  kind_of: String,
  default: lazy { |r| "service[nginx-#{r.name}]" }

# Source of the main configuration file
# @since 0.1.0
property :source,
  kind_of: String,
  default: 'nginx.conf.erb'

# Cookbook containing source of the main configuration file
# @since 0.1.0
property :cookbook,
  kind_of: String,
  default: 'nginx_resources'

# Top level variables referenced by the configuration file and by
# dependant resources
# @since 0.1.0
property :variables,
  kind_of: Hash,
  coerce: proc { |v|
    case v
    when Chef::Node::ImmutableMash then v.to_hash
    else v
    end
  },
  default: {}

# Nginx parameters to add to the configuration file
# @since 0.1.0
property :configs,
  kind_of: Hash,
  coerce: proc { |v|
    case v
    when Chef::Node::ImmutableMash then v.to_hash
    else v
    end
  }

# Action which will create the directory structure and main configuration
# file.
# @since 0.1.0
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
      bool ? 'on' : 'off'
    end

    notifies :reload, resources(new_resource.service), :delayed
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
