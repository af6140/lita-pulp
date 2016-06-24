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
    is_expected.to route_command('pulp rpm search cosmos in dev').to(:rpm_search)
    is_expected.to route_command('pulp puppet search cosmos').to(:puppet_search)
    is_expected.to route_command('pulp puppet search cosmos in dev').to(:puppet_search)
    is_expected.to route_command('pulp puppet copy -s forge_dev --to forge_qa --author entertainment --name cicd_test --version 0.1.33-pre100079-rev159b6f9 -d -p').to(:copy_puppet)
  end

  describe '#rpm_search' do
    it 'search rpm without repo' do
      send_command("pulp rpm search cosmos")
      puts "*********************"
      #puts replies
    end
    it 'search rpm with repo' do
      send_command("pulp rpm search cosmos in ent-cent7-qa")
      puts "*********************"
      #puts replies
    end
  end

  describe '#puppet_search' do
    it 'search puppet without repo' do
      send_command("pulp puppet search cicd_test")
      puts "*********************"
      #puts replies
    end
    it 'search puppet with repo' do
      send_command("pulp puppet search cicd_test in forge_dev")
      puts "*********************"
      #puts replies
    end

    it 'search puppet without author name' do
      send_command("pulp puppet search entertainment/cicd_test")
      puts "*********************"
      #puts replies
    end
  end

  describe '#copy_puppet_between_repo' do
    it 'copy puppet module' do
      send_command("pulp puppet copy -s forge_dev --to forge_qa --author entertainment --name cicd_test --version 0.1.33-pre100079-rev159b6f9")
    end
    it 'copy puppet module delete new and publish' do
      send_command("pulp puppet copy -s forge_dev --to forge_qa --author entertainment --name cicd_test --version 0.1.33-pre100079-rev159b6f9 -d -p")
    end
  end
end
