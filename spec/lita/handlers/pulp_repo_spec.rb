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
    is_expected.to route_command('pulp create rpm repo --repo_id rpm_repo_1 --name "test rpm repo"').to(:cmd_create_rpm_repo)
    is_expected.to route_command('pulp create puppet repo --repo_id puppet_repo_1 --name "test puppet repo"').to(:cmd_create_puppet_repo)
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

  describe '#create puppet repo' do
    it 'should create repo_puppet_1 successfully' do
      send_command('pulp create puppet repo --repo_id repo_puppet_1 --name "test puppet repo 1" --description "Test Puppet REPO1" --remove_missing ')
      puts replies
    end
    it 'should create repo_puppet_2 successfully' do
      send_command('pulp create puppet repo --repo_id repo_puppet_2 --name "test puppet repo 2" --description "Test Puppet REPO2" --remove_missing ')
      puts replies
    end
  end

  describe '#rpm_repos' do
    it 'list rpm repos' do
      send_command("pulp rpm repos")
      expect(replies.last).to match(/repo_rpm_1|repo_rpm_2/)
    end
  end

  describe '#puppet_repos' do
    it 'list puppet repos' do
      send_command("pulp puppet repos")
      #puts replies
      expect(replies.last).to match(/repo_puppet_1|repo_puppet_2/)
    end
  end

  describe '#show repo detail' do
    it 'show a rpm repo detail' do
      send_command('pulp show repo repo_rpm_1')
      expect(replies.last).to match(/id.*repo_rpm_1/)
      expect(replies.last).to match(/"http".*true/)
      expect(replies.last).to match(/"https".*false/)
    end
    it 'show a puppet repo detail' do
      send_command('pulp show repo repo_puppet_1')
      expect(replies.last).to match(/id.*repo_puppet_1/)
      expect(replies.last).to match(/"serve_http".*true/)
      expect(replies.last).to match(/"serve_https".*false/)
    end
  end

  describe '#sync repo' do
    it 'sync a repository' do
      send_command('pulp sync repo_rpm_1')
      #puts replies
      expect(replies.last).to match(/task_id/)
    end
  end

  describe '#publish repo' do
    it 'publish a repository' do
      send_command('pulp publish repo_rpm_1')
      expect(replies.last).to match(/task_id/)
    end
  end

end
