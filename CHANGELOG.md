# nginx\_resources cookbook changelog

## v0.4.0
* Update proxy\_fastcgi template syntax

## v0.3.1
* Add fastcgi_pass to locations handling

## v0.3.0
* Update installation recipes to split the download and build phases
* Add ngx lua ssl patch

## v0.2.6
* Resolve issue with lua.so loading
* Install ngx resty_core which no longer seems to be automatic

## v0.2.5
* Resolve logging syntax issue

## v0.2.4
* Bugfix rubocop errors

## v0.2.3
* Ensure glib module installs the zlib dependencies
* Ensure health module logs to access log by default
* Ensure error log logs to main config dir

## v0.2.2
* Update dependencies for build-essential 6

## v0.2.1
* Rubocop you HAVE FAILED ME! Bugfixes

## v0.2.0
* Bugfixes
* Rubocop style changes
* BREAKING CHANGE: `node['nginx_resources']['source']['include_recipes']` is now a Hash of bools rather than an Array in order to better support attribute precedence mergin.

## v0.1.4
* Fix copy-paste type in user creation recipe
* Streamline service definition

## v0.1.2
* Resolve timing issue with service templates
* Resolve bug service notification issue due to bug in chef where it errors
  out if a nested resource is passed a notify resource by string rather than
  object

## v0.1.1
* Remove apt version pin to prevent conflict with newrelic

## v0.1.0
* Initial release
