require 'spork'
require 'rspec'

Spork.prefork do
  # this block will run when Spork starts up

  ### Libraries
  require 'active_support/core_ext'  
end

Spork.each_run do
  require File.expand_path("../../config/init", __FILE__)
end