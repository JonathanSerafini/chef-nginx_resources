resource_name :nginx_resources_module

property :instance,
  kind_of: String,
  default: "default"

property :priority,
  kind_of: String,
  coerce: proc { |v| v.to_s },
  default: "50"

property :version,
  kind_of: String,
  required: true

property :checksum,
  kind_of: String,
  required: true,
  desired_state: false

property :source,
  kind_of: String,
  required: true,
  desired_state: false

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

property :archive,
  kind_of: String,
  desired_state: false

property :archive_depth,
  kind_of: Integer,
  desired_state: false

property :enabled,
  kind_of: [TrueClass, FalseClass],
  default: true

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
    category  "module"
    source    "module/generic.conf.erb"
    variables template_variables
    enabled   new_resource.enabled
    only_if { new_resource.module_path }
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
    category  "module"
    action    :delete
  end

  node.default['nginx_resources']['source'].tap do |source_attr|
    source_attr['external_modules'][source_deploy] = nil
  end
end

action_class do
  # chef/chef#4537
  def whyrun_supported?
    true
  end

  def template_variables
    { 
      "module_path" => new_resource.module_path,
    }
  end
end

