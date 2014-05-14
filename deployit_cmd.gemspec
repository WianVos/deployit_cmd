# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','deployit_cmd','version.rb'])
spec = Gem::Specification.new do |s| 
  s.name = 'deployit_cmd'
  s.version = DeployitCmd::VERSION
  s.author = 'Your Name Here'
  s.email = 'your@email.address.com'
  s.homepage = 'http://your.website.com'
  s.platform = Gem::Platform::RUBY
  s.summary = 'A description of your project'
  s.files = `git ls-files`.split("
")
  s.require_paths << 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.rdoc','deployit_cmd.rdoc']
  s.rdoc_options << '--title' << 'deployit_cmd' << '--main' << 'README.rdoc' << '-ri'
  s.bindir = 'bin'
  s.executables << 'deployit_cmd'
  s.add_development_dependency('rake')
  s.add_development_dependency('rdoc')
  s.add_development_dependency('aruba')
  s.add_runtime_dependency('gli','2.9.0')
  s.add_runtime_dependency('active_attr')
  s.add_runtime_dependency('xml-simple')
  s.add_runtime_dependency('rest_client')
  s.add_runtime_dependency('nokogiri')


end
