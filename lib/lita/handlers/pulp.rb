module Lita
  module Handlers
    class Pulp < Handler
      # insert handler code here
      namespace 'Pulp'
      config :username, required: true, type: String
      config :password, required: true, type: String
      config :url, required: true, type: String
      config :api_path, required: true, type: String
      config :verify_ssl, required:true, types: [TrueClass, FalseClass], default: false

      include ::PulpHelper::Misc
      include ::PulpHelper::Repo

      route(
       /^pulp\srpm\srepos$/,
       :rpm_repos,
       command: true,
       help: {
         t('help.repos.syntax') => t('help.repos.desc')
       }
      )

      route(
       /^pulp\spuppet\srepos$/,
       :puppet_repos,
       command: true,
       help: {
         t('help.repos.syntax') => t('help.repos.desc')
       }

      )

      def rpm_repos(response)
          result=list_repo(REPO_TYPE_RPM)
          response.reply result
      end

      def puppet_repos(response)
          result=list_repo(REPO_TYPE_PUPPET)
          response.reply result
      end

      Lita.register_handler(self)
    end
  end
end
