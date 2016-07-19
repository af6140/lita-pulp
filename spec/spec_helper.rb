require 'lita-keyword-arguments'
require "lita-pulp"
require "lita/rspec"
require "docker/compose"

# A compatibility mode is provided for older plugins upgrading from Lita 3. Since this plugin
# was generated with Lita 4, the compatibility mode should be left disabled.
Lita.version_3_compatibility_mode = false

require 'vcr'


VCR.configure do |c|
  c.default_cassette_options = {
    :match_requests_on => [:method, :uri, :host, :headers, :query, :body, :path]
  }
  c.ignore_request do |request |
    uri = request.uri
    ignore = false
    method = request.method
    if uri.end_with?('repositories/') && method.to_s == 'post'
      ignore = true
    end
    ignore == true
  end
  c.cassette_library_dir = 'spec/fixtures/cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
end


RSpec.configure do |config|
  config.before :suite do
    puts "before suite, set up"
    work_dir = File.expand_path('../fixtures', __FILE__)
    if ENV['LITA_provision'] != 'no'
      @compose = Docker::Compose::Session.new dir:work_dir
      @compose.up detached:true, no_build: true
    end
  end
  config.after :suite do
    puts "after suite, clean up"
    if ENV['LITA_destroy'] != 'no'
      @compose.stop
      sleep 2
      @compose.rm force:true, volumes:true
    end
  end
  config.before do
    registry.register_handler(Lita::Handlers::Pulp)
    registry.register_hook(:trigger_route, Lita::Extensions::KeywordArguments)
  end
end
