# encoding: utf-8

require "albino"

# Oh God, I wish the filters would support arguments,
# so we could pass the language as an argument rather
# than generate dozens of stupid anonymous modules!
module Haml::Filters
  FORMATS ||= [:ruby, :javascript, :haml]

  FORMATS.each do |format|
    Module.new do
      # Haml filters are identified by name of the module.
      metaclass = class << self; self; end
      metaclass.send(:define_method, :name) do
        format.to_s.capitalize
      end

      include Base

      define_method(:render_with_options) do |text, options|
        Albino.colorize(text, format)
      end
    end
  end
end
