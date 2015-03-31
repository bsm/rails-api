# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 2.0.0'
  s.required_rubygems_version = ">= 1.8.0"

  s.name        = "bsm-rails-api"
  s.summary     = "BSM's Rails API helpers"
  s.description = ""
  s.version     = '0.2.1'

  s.authors     = ["Dimitrij Denissenko"]
  s.email       = "dimitrij@blacksqaremedia.com"
  s.homepage    = "https://github.com/bsm/rails-api"
  s.licenses    = ["MIT"]

  s.require_path = 'lib'
  s.files        = Dir['lib/**/*']

  s.add_dependency "railties", ">= 4.2.0", "< 5.0.0"
  s.add_dependency "actionpack"
  s.add_dependency "activesupport"

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
end
