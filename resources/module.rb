# Module resource wraps Source and Config to ensure that we download source
# tarballs, unpack them, update node attributes for module loading as well as
# add the module configuration file to an instance.
#
resource_name :nginx_resources_module

# Name of the nginx_resources_instance resource which this belongs to
# @since 0.1.0
property :instance,
  kind_of: String,
  default: 'default'

# A priority prefix for the configurtion path in order to load in order
# @since 0.1.0
property :priority,
  kind_of: String,
  coerce: proc { |v| v.to_s },
  default: '50'

# The version to be compiled
# @since 0.1.0
property :version,
  kind_of: String,
  required: true

# The checksum of the source archive file
# @since 0.1.0
property :checksum,
  kind_of: String,
  required: true,
  desired_state: false

# The URL from which to download the archive file
# @since 0.1.0
property :source,
  kind_of: String,
  required: true,
  desired_state: false

# Pack to the module .so file used in the configuration file
# @since 0.1.0
property :module_path,
  kind_of: String,
  coerce: proc { |v|
    v = case v
        when /^\// then v
        when /^modules\// then v
        else "modules/#{v}"
        end
    v = case v
        when /\.so$/ then v
        else "#{v}.so"
        end
    v
  }

# The name of the archive file we have downloaded and stored on disk
# @since 0.1.0
property :archive,
  kind_of: String,
  desired_state: false

# The folders to strip after extracting the archive
# @since 0.1.0
property :archive_depth,
  kind_of: Integer,
  desired_state: false

# Whether nginx should load this configuration file automatically or not. The
# provider will ensure to remove the .conf suffix when not enabled.
# @since 0.1.0
property :enabled,
  kind_of: [TrueClass, FalseClass],
  default: true

# An optional ruby block to evaluate within the context of this resource.
# @since 0.1.0
def hook(&block)
  @hook = block if block_given?
  @hook
end

action :install do
  source = nginx_resources_source new_resource.name do
    %w(version checksum source archive archive_depth).each do |prop|
      value = new_resource.send(prop)
      send(prop, value) unless value.nil?
    end
  end

  if hook
    recipe_eval(&hook)
  end

  nginx_resources_config new_resource.name do
    instance  new_resource.instance
    priority  new_resource.priority
    category  'module'
    source    'module/generic.conf.erb'
    variables template_variables
    enabled   new_resource.enabled
    only_if do
      new_resource.module_path
    end
  end

  node.default['nginx_resources']['source'].tap do |source_attr|
    source_attr['external_modules'][source.deploy_path] = 'dynamic'
  end
end

action :delete do
  source = nginx_resources_source new_resource.name do
    %w(version archive).each do |prop|
      value = new_resource.send(prop)
      send(prop, value) unless value.nil?
    end
    version new_resource.version
    archive new_resource.archive
    action  :delete
  end

  nginx_resources_config new_resource.name do
    instance  new_resource.instance
    category  'module'
    action    :delete
  end

  node.default['nginx_resources']['source'].tap do |source_attr|
    source_attr['external_modules'][source_deploy] = nil
  end
end

action_class do
  # Support whyrun
  def whyrun_supported?
    true
  end

  def template_variables
    {
      'module_path' => new_resource.module_path
    }
  end
end
