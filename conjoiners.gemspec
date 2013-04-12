Gem::Specification.new do |s|
  s.name	= 'conjoiners'
  s.authors     = 'Pavlo Baron'
  s.version	= '0.0.0'
  s.summary     = 'conjoiners - multi-platform / multi-language reactive programming library (for Ruby)'
  s.license    = 'Apache License, Version 2.0'

  s.files       = Dir['lib/**/*.rb']

  s.add_dependency 'ffi-rzmq', '~> 1.0.0'
  s.add_dependency 'json', '>= 1.7.7'
end
