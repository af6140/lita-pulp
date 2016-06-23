require 'runcible'

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
  end
end
