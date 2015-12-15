# -*- coding: utf-8 -*-
Gem::Specification.new do |s|
  s.name        = 'gly'
  s.version     = '0.0.1'
  s.date        = '2015-12-15'
  s.summary     = 'Writer-friendly Gregorian notation format compiling to gabc'

  s.description = File.read 'README.md'

  s.authors     = ['Jakub Pavlík']
  s.email       = 'jkb.pavlik@gmail.com'
  s.files       = (Dir['bin/*'] + Dir['lib/**/*'] +
                   Dir['tests/**/*'])
  s.executables = ['gly']
  s.homepage    = 'http://github.com/igneus/gly'
  s.licenses    = ['MIT']

  s.add_dependency 'thor', '~> 0'
  s.add_development_dependency 'minitest-reporters', '~> 1'
end
