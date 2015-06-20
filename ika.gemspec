$:.push File.expand_path('../lib', __FILE__)

require 'ika/version'

Gem::Specification.new do |s|
  s.name        = 'ika'
  s.version     = Ika::VERSION
  s.authors     = ['Makoto NAKAYA', 'Shoya TANAKA']
  s.email       = ['nakaya@aqte.net', 'tanaka@aqte.net']
  s.homepage    = 'https://github.com/Aqutras/ika'
  s.summary     = 'Implement Import/Export feature to ActiveRecord models.'
  s.description = 'Implement Import/Export feature to ActiveRecord models.'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  s.add_dependency 'rails', '~> 4.2.0'

  s.add_development_dependency 'sqlite3', '~> 1.0'
  s.add_development_dependency 'rspec-rails', '~> 3.0'
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'json_expressions'
  s.add_development_dependency 'coveralls'
end
