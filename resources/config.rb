# Config resource which represents an nginx configuration file.
#
resource_name :nginx_resources_config

# Name of the nginx_resources_instance resource which this belongs to
# @since 0.1.0
property :instance,
  kind_of: String,
  default: 'default'

# A priority prefix for the configurtion path in order to load in order
# @since 0.1.0
property :priority,
  kind_of: [NilClass, String],
  coerce: proc { |v| v.to_s unless v.nil? },
  default: lazy { |r|
    case r.category
    when 'include' then nil
    else '50'
    end
  }

# The etc subfolder into which to install. This is also used to organize the
# template source files.
# @since 0.1.0
property :category,
  kind_of: String,
  equal_to: %w(config module include site),
  required: true

# Name of the configuration file without priority prefix
# @since 0.1.0
property :filename,
  kind_of: String,
  coerce: proc { |v| v =~ /\.conf$/ ? v : "#{v}.conf" },
  default: lazy { |r| "#{r.name}.conf" }

# Name of the cookbook in which the template source may be found
# @since 0.1.0
property :cookbook,
  kind_of: String,
  default: 'nginx_resources'

# Path to the template source file
# @since 0.1.0
property :source,
  kind_of: String,
  default: lazy { |r| "#{r.category}/#{r.filename}.erb" }

# Whether the source file exists in a cookbook or on disk
# @since 0.1.0
property :local,
  kind_of: [TrueClass, FalseClass],
  default: false

# Whether nginx should load this configuration file automatically or not. The
# provider will ensure to remove the .conf suffix when not enabled.
# @since 0.1.0
property :enabled,
  kind_of: [TrueClass, FalseClass],
  default: true

# Template variables to provide. Generally used to provide configurations
# other than nginx parameters and which will automatically have the
# nginx_resources_instances paths injected.
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

# Template nginx parameters to provide as variables under the `configs` hash.
# @since 0.1.0
property :configs,
  kind_of: Hash,
  coerce: proc { |v|
    case v
    when Chef::Node::ImmutableMash then v.to_hash
    else v
    end
  },
  default: {}

action :create do
  # Configuration file template
  template template_path do
    local     new_resource.local
    source    new_resource.source
    cookbook  new_resource.cookbook
    variables template_variables

    # A helper method to convert a boolean to on/off
    helper :on_off do |bool|
      bool ? 'on' : 'off'
    end

    # A helper method to convert a hash into a string of key=value
    helper :hash_params do |hash|
      hash.map do |k, v|
        if [false, nil].include?(v) then next
        elsif v == true then k
        else "#{k}=#{v}"
        end
      end.join(' ')
    end

    # A helper method to join arrays to a string
    helper :array_string do |array, delim=','|
      Array(array).join(delim)
    end

    # A helper method to automatically wrap on_off/array_string/hash_params
    helper :nginx_value do |value|
      value = case value
              when TrueClass, FalseClass then on_off(value)
              when Array then array_string(value)
              when Hash then hash_params(value)
              else value.to_s
              end
      value
    end

    # A helper method to convert configuration hashes to nginx syntax
    helper :nginx_param do |name, value, options = {}|
      options = {
        'prefix' => nil,
        'ignore' => nil,
        'params' => nil
      }.merge(options)

      unless Array(options['ignore']).include?(name) or value.nil?
        value = nginx_value(value)
        value << " #{nginx_value(options['params'])}" if options['params']
        name  = "#{options['prefix']} #{name}" if options['prefix']
        "#{name} #{value};"
      end
    end

    notifies :reload, resources(nginx_instance_resource.service), :delayed
  end

  # Support potentially deleting duplicates when the priority changes
  duplicates = []
  duplicates.concat(::Dir.glob(template_enabled_path('*')))
  duplicates.concat(::Dir.glob(template_available_path('*')))
  duplicates.delete(template_path)

  if duplicates.count > 1
    fatal! "#{desired} multiple duplicate files have been found"
  end

  duplicates.each do |duplicate|
    file duplicate do
      action :delete
    end
  end
end

action :delete do
  file template_path do
    action :delete
    notifies :reload, resources(nginx_instance_resource.service), :delayed
  end
end

action_class do
  # Load a shared library providing the nginx_instances_resources method
  include NginxResources::Mixin::DiscoveryMethods

  # Support whyrun
  def whyrun_supported?
    true
  end

  # Locate the nginx_resources_instance resource this config belongs to
  def nginx_instance_resource(&block)
    @nginx_instance = find_instance_resource(new_resource.instance, &block)
  end

  # Folder into which to install the template file
  def template_conf_dir
    category_dir =  case new_resource.category
                    when 'config' then 'conf.d'
                    when 'module' then 'module.d'
                    when 'include' then 'include.d'
                    when 'site' then 'site.d'
                    end
    ::File.join(nginx_instance_resource.conf_dir, category_dir)
  end

  # Automatically add the prefix if required
  def template_prefix_filename(prefix = nil)
    prefix = new_resource.priority if prefix.nil?
    prefix = "#{prefix}-" unless prefix.nil?
    "#{prefix}#{new_resource.filename}"
  end

  def template_enabled_path(prefix = nil)
    ::File.join(template_conf_dir, template_prefix_filename(prefix))
  end

  def template_available_path(prefix = nil)
    template_enabled_path(prefix).sub(/\.conf$/, '')
  end

  def template_path
    new_resource.enabled ? template_enabled_path : template_available_path
  end

  def template_variables
    variables = {
      'name'      => new_resource.name,
      'pid_dir'   => nginx_instance_resource.pid_dir,
      'log_dir'   => nginx_instance_resource.log_dir,
      'conf_dir'  => nginx_instance_resource.conf_dir,
      'spool_dir' => nginx_instance_resource.spool_dir
    }
    variables.merge!(new_resource.variables)
    variables['configs'] = new_resource.configs
    variables
  end
end
