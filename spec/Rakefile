require 'puppetlabs_spec_helper/rake_tasks'

# Enable puppet-lint for all manifests: rake lint
require 'puppet-lint/tasks/puppet-lint'
PuppetLint.configuration.send("disable_80chars")    # no warnings on lines over 80 chars.
PuppetLint.configuration.send("disable_class_inherits_from_params_class")
PuppetLint.configuration.ignore_paths = ["spec/fixtures/**/*.pp"]
