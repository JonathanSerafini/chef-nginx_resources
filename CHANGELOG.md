# nginx\_resources cookbook changelog

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
