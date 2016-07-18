require "spec_helper"

vcr_options = { :record => :new_episodes }

describe Lita::Handlers::Pulp, lita_handler: true, :vcr => vcr_options do

  before do
    registry.config.handlers.pulp.url="https://localhost:8843"
    registry.config.handlers.pulp.api_path="/pulp/api/v2/"
    registry.config.handlers.pulp.username="admin"
    registry.config.handlers.pulp.password="admin"
    registry.config.handlers.pulp.verify_ssl=false
  end

  it do
    is_expected.to route_command('pulp rpm repos').to(:rpm_repos)
    is_expected.to route_command('pulp puppet repos').to(:puppet_repos)
    is_expected.to route_command('pulp show repo test').to(:show_repo)
    is_expected.to route_command('pulp sync test').to(:repo_sync)
    is_expected.to route_command('pulp publish test').to(:repo_publish)
    is_expected.to route_command('pulp create rpm repo --repo_id rpm_repo_1 --name "test repo"').to(:cmd_create_rpm_repo)
  end


  describe '#create rpm repo' do
    it 'should create repo_rpm_1 successfully' do
      send_command('pulp create rpm repo --repo_id repo_rpm_1 --name "test repo" --description "Test REPO" --relative_url "rpm/test/x86_64" ')
      puts replies
    end
    it 'should create repo_rpm_2 successfully' do
      send_command('pulp create rpm repo --repo_id repo_rpm_2 --name "test repo 2" --description "Test REPO2" --relative_url "rpm/test2/x86_64" ')
      puts replies
    end
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

  describe '#show repo detail' do
    it 'show a rpm repo detail' do
      send_command('pulp show repo ent-cent7-dev')
      puts "************"
      puts replies
    end
    it 'show a puppet repo detail' do
      send_command('pulp show repo forge_dev')
      puts "************"
      puts replies
    end
  end

  describe '#sync repo' do
    it 'sync a repository' do
      send_command('pulp sync forge_dev')
      puts "***********"
      puts replies
    end
  end

  describe '#publish repo' do
    it 'publish a repository' do
      send_command('pulp publish ent-cent7-qa')
      puts "***********"
      puts replies
    end
  end

end
