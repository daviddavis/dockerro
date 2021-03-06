$LOAD_PATH.push File.expand_path('../lib', __FILE__)

require 'dockerro/version'

Gem::Specification.new do |s|
  s.name           = 'dockerro'
  s.version        = Dockerro::VERSION
  s.date           = Date.today.to_s
  s.authors        = ['Adam Ruzicka']
  s.email          = ['aruzicka@redhat.com']
  s.homepage       = 'http://github.com/adamruzicka/dockerro'
  s.licenses       = ['GPL-2']
  s.files          = Dir['{app,config,db,lib}/**/*', 'LICENSE', 'README.md']
  s.files         += Dir["engines/bastion_dockerro/{app,vendor,lib,config}/**/*"]
  s.files         += Dir["engines/bastion_dockerro/{README.md,bastion_dockerro.gemspec}"]
  s.require_paths  = ["lib"]
  # s.test_files = Dir['test/**/*']
  s.add_dependency 'docker-api', '~> 1.13'
  s.add_dependency 'dynflow', '~> 0.7.5'
  s.add_dependency 'rails'
  s.add_dependency "strong_parameters"
  s.add_dependency 'foreman-tasks', '~> 0.6.10'
  s.add_dependency 'katello'
  s.add_development_dependency 'rubocop', '~> 0.26'

end
