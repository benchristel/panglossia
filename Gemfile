source 'http://rubygems.org'

###  Awesome set of core class extensions, used by Rails
gem 'activesupport'

group :development do

  ###  runs our tests
  gem 'rspec'

  ###  watches for file changes and runs tasks automatically
  gem 'guard-rspec'
  gem 'guard-spork'
  gem 'guard-bundler'
  ###  allows Guard to monitor changes to directory structure (on Mac OS)
  gem 'rb-fsevent', :require => false if RUBY_PLATFORM =~ /darwin/i

  ###  preloads libraries and keeps them in memory so specs will run without
  #    waiting to load each time
  gem 'spork'

end

