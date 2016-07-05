# Build resource which downloads and compiles nginx.
#
resource_name :nginx_resources_build

# The version to be compiled
# @since 0.1.0
property :version,
  kind_of: String,
  default: lazy {
    node['nginx_resources']['source']['version']
  }

# The instance root directory
# @since 0.1.0
property :root_dir,
  kind_of: String,
  desired_state: false,
  required: true

# The path of the nginx binary
# @since 0.1.0
property :sbin_path,
  kind_of: String,
  required: true

# The path of the primary configuration file
# @since 0.1.0
property :conf_path,
  kind_of: String,
  required: true

# The folder into which nginx is installed
# @since 0.1.0
property :prefix,
  kind_of: String,
  default: lazy { |r|
    "#{r.root_dir}/var/#{r.version}"
  }

# The name of the nginx service
# @since 0.1.0
property :service,
  kind_of: String,
  desired_state: false,
  required: true

# The checksum of the source archive file
# @since 0.1.0
property :checksum,
  kind_of: String,
  desired_state: false,
  default: lazy {
    node['nginx_resources']['source']['checksum']
  }

# The URL from which to download the archive file
# @since 0.1.0
property :source,
  kind_of: String,
  desired_state: false,
  default: lazy { |r|
    "http://nginx.org/download/nginx-#{r.version}.tar.gz"
  }

# The name of the archive file we have downloaded and stored on disk
# @since 0.1.0
property :archive,
  kind_of: String,
  desired_state: false,
  default: lazy { |r| 
    "nginx-#{r.version}.tar.gz"
  }

# The folders to strip after extracting the archive
# @since 0.1.0
property :archive_depth,
  kind_of: Integer,
  desired_state: false,
  default: 1

# Environment variables to define when executing commands
# @since 0.1.0
property :environment,
  kind_of: Hash,
  desired_state: false,
  default: lazy { |r|
    node['nginx_resources']['source']['environment'].to_hash
  }

# The nginx builtin modules to enable or disable
# @since 0.1.0
property :builtin_modules,
  kind_of: Hash,
  default: lazy { |r|
    node['nginx_resources']['source']['builtin_modules'].to_hash
  }

# The nginx external modules to enable. These are generally packages
# downloaded from third parties.
# @since 0.1.0
property :external_modules,
  kind_of: Hash,
  default: lazy { |r|
    node['nginx_resources']['source']['external_modules'].to_hash
  }

# Non-module configure arguments to use when compiling
# @since 0.1.0
property :additional_configure_flags,
  kind_of: Array,
  default: lazy { |r|
    node['nginx_resources']['source']['additional_configure_flags'].to_a
  }

# Whether we should force a re-compile of nginx, irrespective of whether 
# the binary compile options have not changed
# @since 0.1.0
property :force_recompile,
  kind_of: [TrueClass, FalseClass],
  default: false

# Determine whether the binary installed matches the desired outcome
# @since 0.1.0
load_current_value do |desired|
  force_recompile false

  builtin_modules Hash.new
  external_modules Hash.new
  additional_configure_flags Array.new

  unless ::File.exists?(desired.sbin_path)
    current_value_does_not_exist!
  end

  shell_out!("#{desired.sbin_path} -V").stderr.each_line do |line|
    case line
    when /^nginx version: nginx\/(.*)\n$/
      version $1
    when /^configure arguments: (.*)\n$/
      configure_arguments = $1.split(' ')
      configure_arguments.each do |argument|
        case argument
        when /^--prefix=(.*)/
          prefix $1
        when /^--conf-path=(.*)/
          conf_path $1
        when /^--sbin-path=(.*)/
          sbin_path $1
        when /^(--with-.*=.*)/
          additional_configure_flags << $1
        when /^--with-([^=]*)/
          builtin_modules[$1] = true
        when /^--without-(.*)/
          builtin_modules[$1] = false
        when /^--add-module=(.*)/
          external_modules[$1] = "static"
        when /^--add-dynamic-module=(.*)/
          external_modules[$1] = "dynamic"
        else
          additional_configure_flags << $1
        end
      end
    end
  end
end

action :install do
  # TODO: Additional investigation needs to be performed regarding this.
  # Without the following block, Lazy{} does not seem to evaluate correctly.
  new_resource.class.state_properties.each do |p|
    new_resource.send(p.name)
  end

  converge_if_changed do
    nginx_resources_source "nginx" do
      %w(version checksum source archive archive_depth).each do |prop|
        value = new_resource.send(prop)
        send(prop, value) unless value.nil?
      end
    end

    bash 'configure_nginx' do
      environment new_resource.environment
      cwd build_path
      code <<-EOH
        ./configure #{configure_flags.join(' ')}
      EOH
    end
  end

  converge_if_changed :version,
    :additional_configure_flags,
    :force_recompile do
      bash 'make_binary' do
        environment new_resource.environment
        cwd build_path
        code <<-EOH
          make -f objs/Makefile binary manpage
        EOH
      end
  end

  converge_if_changed :version,
    :builtin_modules,
    :external_modules,
    :force_recompile do
      bash 'make_modules' do
        environment new_resource.environment
        cwd build_path
        code <<-EOH
          make -f objs/Makefile modules
        EOH
      end
  end

  converge_if_changed do
    bash 'make_install' do
      environment new_resource.environment
      cwd build_path
      code <<-EOH
        make install
        rm #{::File.dirname(new_resource.conf_path)}/*.default
      EOH
    end
    notifies :restart, new_resource.service, :delayed
  end
end

action :remove do
  nginx_resources_source new_resource.name do
    %w(version archive).each do |prop|
      value = new_resource.send(prop)
      send(prop, value) unless value.nil?
    end
    action  :delete
    notifies :stop, new_resource.service, :delayed
  end

  file new_resource.sbin_path do
    action :delete
  end

  directory new_resource.prefix do
    recursive true
    action :delete
  end

  file new_resource.conf_path do
    action :delete
  end
end

action_class do
  # Include the shell_out! helper
  include Chef::Mixin::ShellOut

  # Support whyrun
  def whyrun_supported?
    true
  end

  # The path where the source resides
  def build_path
    "#{Chef::Config['file_cache_path']}/nginx-#{new_resource.version}"
  end

  def builtin_module_flags
    new_resource.builtin_modules.map do |name, enabled|
      if enabled
      then "--with-#{name}"
      else "--without-#{name}"
      end
    end.sort
  end

  def external_module_flags
    new_resource.external_modules.map do |path, category|
      case category.to_s
      when "dynamic" then "--add-dynamic-module=#{path}"
      when "static" then "--add-module=#{path}"
      end
    end.sort
  end

  def configure_flags
    [ 
      "--prefix=#{new_resource.prefix}",
      "--conf-path=#{new_resource.conf_path}",
      "--sbin-path=#{new_resource.sbin_path}"
    ].
    concat(new_resource.additional_configure_flags).
    concat(builtin_module_flags).
    concat(external_module_flags).
    uniq.
    sort
  end
end
