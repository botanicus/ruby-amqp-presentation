#!/usr/bin/env rackup

# This is just for development. The only thing it does
# is serving of static files from the output/ directory.

use Rack::Head

class Server
  def initialize(root)
    @file_server = Rack::File.new(root)
  end

  def call(env)
    path = env["PATH_INFO"]
    returned = @file_server.call(env)
    if returned[0] == 404 && env["PATH_INFO"].end_with?("/")
      env["PATH_INFO"] = File.join(env["PATH_INFO"], "index.html")
      returned = @file_server.call(env)
      log "[404]", env["PATH_INFO"] if returned[0] == 404
      returned
    else
      returned
    end
  end

  private
  def log(bold, message)
    warn "~ \033[1;31m#{bold}\033[0m #{message}"
  end
end

# /stats/:slug
# ?start_time=%d&end_time=%d
# map("/stats") do |env|
#     title, time, first, last
#     start_time, end_time
#
#     # stats = {date => {slides: {slide_title => time}}, start_time: time, end_time: time, total: total}
#     stats = YAML::load_file("stats.yml")
#     date = Time.now.strftime("%d/%m/%Y")
#     slides = stats[date][:slides] || Hash.new
#     stats[date] = {slides: slides.merge(title => time)}
#
#     # Overall statistics.
#     stats[date][:start_time] = start_time if start_time
#     stats[date][:end_time] = end_time if end_time
#     stats[date][:total_time] = end_time - stats[date][:start_time]
#
#     File.open("stats.yml", "w") do |file|
#       file.puts(stats.to_yaml)
#     end
# end

run Server.new("output")
