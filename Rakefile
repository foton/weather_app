# frozen_string_literal: true

# #require "bundler/gem_tasks"
# require 'rubygems'
require 'bundler'
# require 'rake'
require 'rake/testtask'
require 'rubocop/rake_task'

begin
  Bundler.setup :default, :development
rescue Bundler::BundlerError => e
  warn e.message
  warn 'Run `bundle install` to install missing gems'
  exit e.status_code
end

RuboCop::RakeTask.new

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/test_*.rb']
end

task default: :test
