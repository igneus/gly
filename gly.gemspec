# -*- coding: utf-8 -*-
require_relative 'lib/gly/version'

Gem::Specification.new do |s|
  s.name        = 'gly'
  s.version     = Gly::VERSION
  s.date        = Gly::RELEASE_DATE.to_s
  s.summary     = 'Writer-friendly Gregorian notation format compiling to gabc'

  s.authors     = ['Jakub Pavlík']
  s.email       = 'jkb.pavlik@gmail.com'
  s.files       = (Dir['bin/*'] + Dir['lib/**/*'] +
                   Dir['tests/**/*'])
  s.executables = ['gly']
  s.homepage    = 'http://github.com/igneus/gly'
  s.licenses    = ['MIT']

  s.add_dependency 'thor'
  s.add_development_dependency 'minitest-reporters', '~> 1'
end
