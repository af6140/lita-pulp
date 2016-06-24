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
        /^pulp\spubish\s(\S+)$/,
        :publish_repo,
        command: true,
        help: {
          t('help.publish_repo.syntax') => t('help.publish_repo.desc')
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
       /^pulp\s+puppet\s+search\s+(?>[a_zA-Z0-9]+\/)?(\S+)(?>\s+in\s+)?(\S+)?$/,
       :puppet_search,
       command: true,
       help: {
         t('help.repos.syntax') => t('help.repos.desc')
       }
      )

      route(
        /^pulp\s+rpm\s+copy\s+from=(\S+)\s+to=(\S+)\s+name=(\S+)\s+version=(\S+)\s+release=(\S+)/i,
        :copy_rpm,
        command: true,
        kwargs: {
          delete_newer: {
            short: "d"
          },
          publish: {
            short: "p"
          }
        },
        help: {
          t("help.copy_rpm_key") => t("help.copy_rpm_value")
        }
      )

      route(
        /^pulp\s+puppet\s+copy\s+from=(\S+)\s+to=(\S+)\s+author=(\S+)\s+name=(\S+)\s+version=(\S+)/i,
        :copy_rpm,
        command: true,
        kwargs: {
          delete_newer: {
            short: "d"
          },
          publish: {
            short: "p"
          }
        },
        help: {
          t("help.copy_rpm_key") => t("help.copy_rpm_value")
        }
      )

      def rpm_repos(response)
        begin
          result=list_repo(REPO_TYPE_RPM)
          response.reply result
        rescue Exception => e
          response.reply e.message
        end
      end

      def puppet_repos(response)
          begin
            result=list_repo(REPO_TYPE_PUPPET)
            response.reply result
          rescue Exception => e
            response.reply e.message
          end
      end

      def publish_repo(response)
          repo_id = response.matchs[0][0]
          if repo_id
            begin
              publish_repo(repo_id)
              response.reply "Command executed successfully"
            rescue Exception => e
              response.reply e.message
            end
          else
            response.reply "No repoistory id specified"
          end
      end

      def rpm_search(response)
        name = response.matches[0][0]
        repo = response.matches[0][1]
        puts "searching for rpm #{name} in repo #{repo}"
        begin
          search_rpm(name, repo)
        rescue Exception => e
          response.reply e.mesage
        end

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
        begin
          result=search_puppet(author, name, repo)
          response.reply result
        rescue Exception => e
          response.reply e.message
        end
      end

      def rpm_copy(response)
         from=response.matchs[0][0]
         to=response.matchs[0][1]
         name=response.matchs[0][2]
         version=response.matchs[0][3]
         release=response.matchs[0][4]
         arch = response.matchs[0][5]
         args = response.extensions[:kwargs]
         delete_newer=args[:delete_newer]||false
         publish=args[:publish]||false
         begin
           copy_rpm_between_repo!(from, to, name, version, release, arch, delete_newer, publish)
           response.reply "Command executed successfully"
         rescue Exception => e
           response.reply e.message
         end
      end

      def puppet_copy(response)
        from=response.matchs[0][0]
        to=response.matchs[0][1]
        author=response.matchs[0][2]
        name=response.matchs[0][3]
        version=response.matchs[0][4]
        args = response.extensions[:kwargs]
        delete_newer=args[:delete_newer]||false
        publish=args[:publish]||false
        begin
          copy_rpm_between_repo!(from, to, author, name, version, delete_newer, publish)
          response.reply "Command executed successfully"
        rescue Excpetion => e
          response.reply e.message
        end
      end

      Lita.register_handler(self)
    end
  end
end
