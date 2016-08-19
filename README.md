nginx_resources cookbook
========================

Installs nginx and dependant modules from source in a modular fashion.

Requirements
------------

### Chef

This cookbook requires Chef 12.7 and above.

### Platforms

At present, only Ubuntu < 16.04 is supported, however adding support for other distributions should be a simple matter.

Recipes
-------

The recipes are designed to create a default nginx installation called `default` and will utilize the resources listed below.

Calling the standard `nginx_resources::default` recipe will cause the following events to occur: 
- `recipes/install_user` is called
  - The www-data user account is optionally created
- `recipes/install_common` is called
  - The `nginx_resources_instance[default]` resource is created
  - A few core and override configuration files are created
  - The default site is created and optionally enabled
  - The service files are created, but not the actual service due to timing
- `recipes/install_modules` is called
  - We iterate through `node['nginx_resources']['source']['include_recipes']`
    and include recipes listed to install dependencies.
- `recipes/install_source` is called
  - Package dependencies are installed
  - The `nginx_resources_build[default]` resources is created
- `recipes/install_service` is called
  - The service is created and optionally started

Usage
-----

1. Within your cookbook, define an *optional* attribute file to customize the `nginx_resources` attributes to your liking. Each and every configuration parameter used by this cookbook is attribute driven.
2. Include the `nginx_resources::default` recipe in your run\_list.
3. Customize the `nginx_resources_site[default]` resource.

Example
```
r = resources('nginx_resources_site[default]')
r.root '/var/www/backofficev2/current/public'
r.listen [80, '443 ssl']
r.locations [
  { 'uri' => '/',
    'try_files' => '$uri @proxy'
  },
  { 'uri' => '/admin/',
    'configs' => {
      'rewrite' => '^/admin/assets(/?.*)$ /assets$1 last'
    },
    'try_files' => '$uri @proxy'
  },
  { 'uri' => '~\.php',
    'configs' => {
      'proxy_send_timeout' => 600,
      'proxy_read_timeout' => 600
    },
    'fastcgi_pass' => '127.0.0.1:9000'
  },
  { 'uri' => '@proxy',
    'configs' => {
      'proxy_send_timeout' => 600,
      'proxy_read_timeout' => 600
    },
    'fastcgi_pass' => '127.0.0.1:9000'
  }
]
r.includes << 'include.d/fastcgi.conf'
r.includes << 'include.d/stub_status.conf'
r.includes << 'include.d/health.conf'
r.enabled true
```

Custom Resources
----------------

A deployment of nginx is comprised of a number of different resources. First, an nginx\_resources\_instance is created to define the basic folder structure. Then, any number of nginx\_resources\_module and nginx\_resources\_config are created to further customize the deployment. Lastly, a nginx\_resources\_build resource is created to compile and install nginx. 

### nginx\_resources\_instance

This resource builds out the folder structure for a specific deployment of nginx and it's dependant configuration files as well as creates the main configuration file. 

Most of the properties have default values which lazilly load node attributes and should not generally need to be modified. Should you need modify them, however, refer to the [source](resources/instance.rb) for more information. 

With the default settings, the following structure will be created: 
```
./var
./var/1.10.1
./var/1.10.1/logs
./var/1.10.1/logs/error.log
./var/1.10.1/html
./var/1.10.1/html/50x.html
./var/1.10.1/html/index.html
./var/1.10.1/modules
./var/1.10.1/modules/ndk_http_module.so
./etc
./etc/include.d
./etc/include.d/stub_status.conf
./etc/include.d/fastcgi.conf
./etc/include.d/health.conf
./etc/site.d
./etc/site.d/20-default
./etc/uwsgi_params
./etc/koi-utf
./etc/conf.d
./etc/conf.d/50-ssl_map.conf
./etc/conf.d/50-ssl.conf
./etc/conf.d/50-realip.conf
./etc/conf.d/50-gzip.conf
./etc/conf.d/20-mime_types.conf
./etc/conf.d/90-custom.conf
./etc/conf.d/20-core.conf
./etc/scgi_params
./etc/fastcgi.conf
./etc/nginx.conf
./etc/module.d
./etc/module.d/20-module_ndk.conf
./etc/fastcgi_params
./etc/mime.types
./etc/koi-win
./etc/win-utf
./sbin
./sbin/nginx
```

### nginx\_resources\_module

This resource downloads an external dependency (ex.: the [lua module](recipes/module_lua.rb)), unpacks it, creates a configuration file for it, and adds the module to the node attributes for the next compile phase. It does so by wrapping nginx\_resources\_source and nginx\_resources\_config.

The following properties are *required* and have no defaults:
- instance: the nginx\_resources\_instance name this module belongs to
- version: the version of this module
- checksum: the checksum of the tarball to download
- source: the url where the tarball is downloaded from

Once downloaded, the resource will inject the module in the global module configure argument attributes found in `node['nginx_resources']['source']['external_modules']`.

Further properties, with defaults, may be modified and are referenced in the [source](resources/module.rb) file.

### nginx\_resources\_source

This resource downloads an external dependency (ex.: the [lua module](recipes/module_lua.rb)) and unpacks it.

The following properties are *required* and have no defaults:
- version: the version of this module
- checksum: the checksum of the tarball to download
- source: the url where the tarball is downloaded from

Further properties, with defaults, may be modified and are referenced in the [source](resources/source.rb) file.

### nginx\_resources\_config

This resource creates a configuration file for use with nginx. Examples of this in practice may be found [here](recipes/install_common.rb).

The following properties are *required* and have no defaults:
- instance: the nginx\_resources\_instance name this module belongs to
- category: the namespace both for source and destination files

Further properties, with defaults, may be modified and are referenced in the [source](resources/config.rb) file.

### nginx\_resources\_build

This resource builds the nginx source code for a specific nginx\_resources\_instance and should be smart enough not to recompile needlessly on each chef run.

The following properties are *required* and have no defaults: 
- root_dir: The root directory containing nginx builds
- sbin_path: The `--sbin-path` or path to the nginx binary
- conf_path: The `--conf-path` or path to the main nginx configuration file
- prefix: The `--prefix` or directory into which to install
- service: The service resource name to notify

Further properties, with defaults, may be modified and are referenced in the [source](resources/build.rb) file.

