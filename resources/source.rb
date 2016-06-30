resource_name :nginx_resources_source

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

property :archive,
  kind_of: String,
  default: lazy { |r| "#{r.name}-#{r.version}.tar.gz" },
  desired_state: false

property :archive_depth,
  kind_of: Integer,
  desired_state: false,
  default: 1

property :archive_path,
  kind_of: String,
  desired_state: false,
  default: lazy { |r|
    ::File.join(
      Chef::Config['file_cache_path'],
      r.archive
    )
  }

property :deploy_path,
  kind_of: String,
  desired_state: false,
  default: lazy { |r|
    ::File.join(
      Chef::Config['file_cache_path'],
      "#{r.name}-#{r.version}"
    )
  }

def hook(&block)
  @hook = block if block_given?
  @hook
end

action :install do
  remote_file new_resource.source do
    source    new_resource.source
    checksum  new_resource.checksum
    path      new_resource.archive_path
    backup    false
  end

  bash 'extract_source' do
    cwd ::File.dirname(new_resource.archive_path)
    code <<-EOH
      mkdir #{new_resource.deploy_path}
      tar zxf #{::File.basename(new_resource.archive_path)} \
           --strip-components=#{new_resource.archive_depth} \
           -C #{new_resource.deploy_path}
    EOH
    not_if do
      ::File.directory?(new_resource.deploy_path)
    end
  end

  if hook
    recipe_eval(&hook)
  end
end

action :delete do
  file new_resource.archive_path do
    action :delete
  end

  directory new_resource.deploy_path do
    recursive true
    action    :delete
  end
end

action_class do
  # chef/chef#4537
  def whyrun_supported?
    true
  end
end

