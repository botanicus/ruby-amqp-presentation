#!/usr/bin/env bundle exec nake
# encoding: utf-8

Encoding.default_internal = "utf-8"
Encoding.default_external = "utf-8"

# Task.tasks.default_proc = lambda { |*| Task[:generate] }

Task.new(:generate) do |task|
  task.description = "Generate static HTML."

  task.define do
    sh "./boot.rb"
  end
end
