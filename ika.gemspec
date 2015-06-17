$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "ika/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "ika"
  s.version     = Ika::VERSION
  s.authors     = ["Makoto NAKAYA", 'Shoya TANAKA']
  s.email       = ["nakaya@aqte.net", 'tanaka@aqte.net']
  s.homepage    = "https://github.com/Aqutras/ika"
  s.summary     = "Implement Import/Export feature to ActiveRecord models."
  s.description = "Implement Import/Export feature to ActiveRecord models."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.2.0"

  s.add_development_dependency "sqlite3"
end
