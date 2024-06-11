# frozen_string_literal: true

require "bundler/gem_tasks"
require "minitest/test_task"

Minitest::TestTask.create

require "rubocop/rake_task"

RuboCop::RakeTask.new

task default: %i[test rubocop]

namespace :rbs do
  task setup: %i[clean inline inline_data]

  task :clean do
    sh "rm", "-rf", "sig/generated"
  end

  task :install do
    sh "bundle", "exec", "rbs", "install"
  end

  task :inline do
    sh "bundle", "exec", "rbs-inline", "lib", "--opt-out", "--output"
  end

  task :inline_data do
    sh "bundle", "exec", "exe/rbs-inline-data", "lib", "--output"
  end
end
