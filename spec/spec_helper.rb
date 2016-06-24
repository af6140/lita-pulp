require 'lita-keyword-arguments'
require "lita-pulp"
require "lita/rspec"

# A compatibility mode is provided for older plugins upgrading from Lita 3. Since this plugin
# was generated with Lita 4, the compatibility mode should be left disabled.
Lita.version_3_compatibility_mode = false

RSpec.configure do |config|
  config.before do
    registry.register_handler(Lita::Handlers::Pulp)
    registry.register_hook(:trigger_route, Lita::Extensions::KeywordArguments)
  end
end

def grab_request(result)
  allow(Runcible::Instance).to receive(:new) { result }
end
