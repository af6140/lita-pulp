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
    is_expected.to route_command('pulp rpm repos').to(:rpm_repos)
    is_expected.to route_command('pulp puppet repos').to(:puppet_repos)
  end

  describe '#rpm_repos' do
    it 'list rpm repos' do
      send_command("pulp rpm repos")
      puts "*********************"
      puts replies
    end
  end

  describe '#puppet_repos' do
    it 'list puppet repos' do
      send_command("pulp puppet repos")
      puts "*********************"
      puts replies
    end
  end
end
