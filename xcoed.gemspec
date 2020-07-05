lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'xcoed/version'

Gem::Specification.new do |spec| # rubocop:disable Metrics/BlockLength
  spec.name          = 'xcoed'
  spec.version       = Xcoed::VERSION
  spec.authors       = ['Igor Makarov']
  spec.email         = ['igormaka@gmail.com']

  spec.summary       = 'Add Swift Packages to an Xcode Project'
  spec.description   = 'Automate adding Swift PM packages to an Xcode project using a ' \
                       'regular `Package.swift` file.'
  spec.homepage      = 'https://github.com/igor-makarov/xcoed/'
  spec.license       = 'MIT'

  spec.files         = `git ls-files lib bin -z`.split("\x0")
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.0.0'

  spec.add_dependency 'hooks', '~> 0.4.1'
  spec.add_dependency 'xcodeproj', '< 2.0.0', '>= 1.10.0'

  # Lock `activesupport` (transitive dependency via `xcodeproj`) to keep supporting system ruby
  spec.add_dependency 'activesupport', '< 5'

  spec.add_development_dependency 'bundler', '>= 1.10'
  spec.add_development_dependency 'os', '~> 1.0'
  spec.add_development_dependency 'pry', '~> 0.10'
  spec.add_development_dependency 'pry-rescue'
  spec.add_development_dependency 'pry-stack_explorer'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'rb-readline', '~> 0.5.4'
  spec.add_development_dependency 'rspec', '~> 3.4.0'
  spec.add_development_dependency 'rubocop', '~> 0.64.0'
  spec.add_development_dependency 'rubocop-git', '~> 0.1.1'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'yard', '~> 0.9'
end
