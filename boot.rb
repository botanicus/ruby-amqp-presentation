#!/usr/bin/env bundle exec ace
# encoding: utf-8

Encoding.default_internal = "utf-8"
Encoding.default_external = "utf-8"

# Setup $LOAD_PATH.
require "bundler/setup"

# Custom setup.
require "pupu/adapters/ace"
Pupu.media_prefix = "/assets"

require "ace"
require "haml"
require "ace/filters/template"
require "nokogiri"
require "redcloth"
require "json"

require_relative "lib/haml-filters"

class Slide < Ace::Item
  before Ace::TemplateFilter, layout: "slide.html"

  def self.slides
    @slides ||= begin
      # Divide metadata and the actual content.
      site = Ace::RawItem.new("content/slides.textile.haml")
      site.parse

      # Process the content as a Haml template.
      # Result of this is <slide>content</slide>.
      engine = Haml::Engine.new(site.content)
      html = engine.render

      document = Nokogiri::HTML(html)

      # Process each slide manually.
      document.css("slide").map do |slide|
        metadata = slide.attributes.reduce(Hash.new) { |attrs, (name, attr)| attrs.merge(name.to_sym => attr.value) }
        if metadata[:title]
          puts "~ Generating slide #{metadata[:title]}."
        else
          puts "~ Generating anonymous slide."
        end

        case slide[:format]
        when "textile"
          textile = RedCloth.new(slide.inner_html)
          content = textile.to_html
        when nil
          content = slide.inner_html
        else
          raise "Format #{slide.metadata[:format]} isn't supported!"
        end

        # Create a new Slide instance for each slide.
        self.new(site, metadata, content)
      end
    end
  end

  # So the problem is that template filter ignores content but use the original_path.
  # BUT how the fuck did it work before????

  # Generator method.
  def self.generate
    self.slides.each do |slide|
      slide.slides = self.slides
      slide.register
    end
  end

  attr_accessor :site, :slides
  def initialize(site, metadata, content)
    @site = site
    super(metadata, content)
  end

  def slug
    number = self.index + 1
    if self.metadata[:title]
      slug = self.metadata[:title].downcase
      slug = slug.tr(" _", "-")
      slug = slug.gsub(/[^-\w\d]/, "")
      slug = "%02d-%s" % [number, slug]
      slug.gsub(/-+/, "-")
    else
      number.to_s
    end
  end

  def index
    self.slides.index(self)
  end

  def next_page
    slide = self.slides[self.index + 1]
    slide.server_path if slide
  end

  def previous_page
    return if self.index == 0
    slide = self.slides[self.index - 1]
    slide.server_path if slide
  end

  def output_path
    "output/slides/#{self.slug}.html"
  end
end

__END__
1) onload & onunload + /stats
2) generator function would add ?time=12
