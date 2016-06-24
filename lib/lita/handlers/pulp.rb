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
      include ::PulpHelper::Unit

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

      route(
       /^pulp\srpm\ssearch\s(\S+)(?>\sin\s)?(\S+)?$/,
       :rpm_search,
       command: true,
       help: {
         t('help.repos.syntax') => t('help.repos.desc')
       }
      )

      route(
       /^pulp\spuppet\ssearch\s(?>[a_zA-Z0-9]+\/)?(\S+)(?>\sin\s)?(\S+)?$/,
       :puppet_search,
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

      def rpm_search(response)
        name = response.matches[0][0]
        repo = response.matches[0][1]
        puts "searching for rpm #{name} in repo #{repo}"
        search_rpm(name, repo)
      end

      def puppet_search(response)
        full_name = response.matches[0][0]
        repo = response.matches[0][1]
        name_spec = full_name.split('/')
        puts "name_spec:#{name_spec}"
        if name_spec.length >1
          author = name_spec[0]
          name = name_spec[1]
        else
          name = full_name
          author = nil
        end
        puts "searching for puppet module #{name} with author: #{author} in repo #{repo}, full_name = #{full_name}"
        search_puppet(author, name, repo)
      end

      def rpm_copy(from, to, name, version, release, delete_newer=false)
      end

      def puppet_copy(from, to, name, version, release, delete_newer=false)
      end

      Lita.register_handler(self)
    end
  end
end
