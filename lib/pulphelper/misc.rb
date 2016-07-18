require 'runcible'
require 'json'

module PulpHelper
  module Misc
    def client
      Runcible::Instance.new({
          :url => config.url,
          :api_path => config.api_path||'pulp/api/v2',
          :user => config.username,
          :http_auth => {:password => config.password},
          :verify_ssl => config.verify_ssl || false,
          :logger => "",
      })
    end
    def get_version
      response = client.resources.repository.call(:get, "/status/")
      version = response['versions']['platform_version']
      version
    end
  end
end
