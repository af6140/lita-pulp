require "spec_helper"

describe Lita::Handlers::Pulp, lita_handler: true do

  before do
    registry.config.handlers.pulp.url="https://pulp.co.epi.web"
    registry.config.handlers.pulp.api_path="/pulp/api/v2/"
    registry.config.handlers.pulp.username="admin"
    registry.config.handlers.pulp.password="admin"
    registry.config.handlers.pulp.verify_ssl=false
  end

  it do
    is_expected.to route_command('pulp rpm search cosmos').to(:rpm_search)
  end

  describe '#rpm_search' do
    it 'search rpm' do
      send_command("pulp rpm search cosmos")
      puts "*********************"
      #puts replies
    end
  end

end
