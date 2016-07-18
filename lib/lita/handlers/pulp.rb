require 'lita-keyword-arguments'
#require 'table_print'

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
      config :pulp_version, required:true, types: String # like 2.7.1 2.7.2 2.8 used to work aroud isse #1394

      include ::PulpHelper::Misc
      include ::PulpHelper::Repo
      include ::PulpHelper::Unit

      route(
       /^pulp\srpm\srepos$/,
       :rpm_repos,
       command: true,
       help: {
         t('help.rpm_repos_key') => t('help.rpm_repos_value')
       }
      )

      route(
       /^pulp\spuppet\srepos$/,
       :puppet_repos,
       command: true,
       help: {
         t('help.puppet_repos_key') => t('help.puppet_repos_value')
       }
      )

      route(
        /^pulp\spublish\s(\S+)$/,
        :repo_publish,
        command: true,
        help: {
          t('help.publish_key') => t('help.publish_value')
        }
      )

      route(
       /^pulp\srpm\ssearch\s(\S+)(?>\sin\s)?(\S+)?$/,
       :rpm_search,
       command: true,
       help: {
         t('help.rpm_search_key') => t('help.rpm_search_value')
       }
      )

      route(
       /^pulp\s+puppet\s+search\s+(?>[a_zA-Z0-9]+\/)?(\S+)(?>\s+in\s+)?(\S+)?$/,
       :puppet_search,
       command: true,
       help: {
         t('help.puppet_search_key') => t('help.puppet_search_value')
       }
      )

      route(
        /^pulp\s+rpm\s+copy/i,
        :copy_rpm,
        command: true,
        kwargs: {
          from: {
            short: "s",
          },
          to: {
            short: "t"
          },
          name: {
            short: "n"
          },
          version: {
            short: "v"
          },
          release: {
            short: "r"
          },
          arch: {
            short: "a"
          },
          delete_newer: {
            short: "d",
            boolean: true
          },
          publish: {
            short: "p",
            boolean: true
          }
        },
        help: {
          t("help.copy_rpm_key") => t("help.copy_rpm_value")
        }
      )


      route(
        /^pulp\s+puppet\s+copy/i,
        :copy_puppet,
        command: true,
        kwargs: {
          from: {
            short: "s",
          },
          to: {
            short: "t"
          },
          author: {
            short: "a"
          },
          name: {
            short: "n"
          },
          version: {
            short: "v"
          },
          delete_newer: {
            short: "d",
            boolean: true
          },
          publish: {
            short: "p",
            boolean: true
          }
        },
        help: {
          t("help.copy_puppet_key") => t("help.copy_puppet_value")
        }
      )

      route(
        /^pulp\s+rpm\s+delete\s+newer/i,
        :delete_newer_rpm,
        command: true,
        kwargs: {
          from: {
            short: "s",
          },
          name: {
            short: "n"
          },
          version: {
            short: "v"
          },
          release: {
            short: "r"
          },
          arch: {
            short: "a"
          },
          publish: {
            short: "p",
            boolean: true
          }
        },
        help: {
          t("help.delete_newer_rpm_key") => t("help.delete_newer_rpm_value")
        }
      )

      route(
        /^pulp\s+puppet\s+delete\s+newer/i,
        :delete_newer_puppet,
        command: true,
        kwargs: {
          from: {
            short: "s",
          },
          author: {
            short: "a"
          },
          name: {
            short: "n"
          },
          version: {
            short: "v"
          },
          publish: {
            short: "p",
            boolean: true
          }
        },
        help: {
          t("help.delete_newer_puppet_key") => t("help.delete_newer_puppet_value")
        }
      )

      route(
        /^pulp\s+show\s+repo\s+(\S+)$/,
        :show_repo,
        command: true,
        help: {
          t('help.show_repo_key') => t('help.show_repo_value')
        }
      )

      route(
        /^pulp\s+sync\s+(\S+)$/,
        :repo_sync,
        command: true,
        help: {
          t('help.sync_repo_key') => t('help.sync_repo_value')
        }
      )

      route(
        /^pulp\s+create\s+rpm\s+repo/i,
        :cmd_create_rpm_repo,
        command: true,
        kwargs: {
          repo_id: {
            short: "r",
          },
          name: {
            short: "n"
          },
          description: {
            short: "d"
          },
          feed: {
            short: "f"
          },
          relative_url: {
            short: "u"
          },
          http: {
            short: "h",
            boolean: true
          },
          https: {
            short: "s",
            boolean: true
          },
          auto_publish: {
            short: 'p',
            boolean: true
          }
        },
        help: {
          t("help.cmd_create_rpm_repo_key") => t("help.cmd_create_rpm_repo_value")
        }
      )


      # route(
      #   /^pulp\s+sync_status\s+(\S+)$/,
      #   :check_sync_status,
      #   command: true,
      #   help: {
      #     t('help.sync_status_key') => t('help.sync_status_value')
      #   }
      # )

      def rpm_repos(response)
        begin
          result=list_repo(REPO_TYPE_RPM)
          #puts "********result"
          s = StringIO.new
          result.each do |r|
            s << "["<< r[:id] << "] : " << r[:name] << ", " << r[:description] << "\n"
          end
          response.reply s.string
        rescue Exception => e
          response.reply e.message
        end
      end

      def puppet_repos(response)
          begin
            result=list_repo(REPO_TYPE_PUPPET)
            #response.reply result.to_json
            s = StringIO.new
            result.each do |r|
              s << "["<< r[:id] << "] : " << r[:name] << ", " << r[:description] << "\n"
            end
            response.reply s.string
          rescue Exception => e
            response.reply e.message
          end
      end

      def show_repo(response)
        repo_id = response.matches[0][0]
        begin
          repo = get_repo(repo_id)
          response.reply JSON.pretty_generate(repo)
        rescue Exception => e
          response.reply e.message
        end
      end
      def repo_publish(response)
          repo_id = response.matches[0][0]
          if repo_id
            unless repo_id
              response.reply "Invalid repository id"
            end
            begin
              result = publish_repo!(repo_id)
              response.reply JSON.pretty_generate(result)
            rescue Exception => e
              response.reply e.message
            end
          else
            response.reply "No repoistory id specified"
          end
      end

      def repo_sync(response)
        #puts "response.matches[0]=#{response.matches[0][0]}"
        repo_id = response.matches[0][0]
        if repo_id
          unless repo_id
            response.reply "Invalid repository id"
          end
          begin
            result=sync_repo!(repo_id)
            response.reply JSON.pretty_generate(result)
          rescue Exception => e
            response.reply e.message
          end
        else
          response.reply "No repoistory id specified"
        end
      end

      #it returns all history with runcible api, which is not an idea behavior
      #though pulp can puerge the task status according to configuration
      def check_sync_status(response)
        puts "response.matches[0]=#{response.matches[0][0]}"
        repo_id = response.matches[0][0]
        if repo_id
          unless repo_id
            response.reply "Invalid repository id"
          end
          begin
            result = sync_status(repo_id)
            response.reply JSON.pretty_generate(result)
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
          # result array of
          # result = {
          #   :name => unit["name"],
          #   :epoch => unit["epoch"],
          #   :version => unit["version"],
          #   :release => unit["release"],
          #   :checksum =>  unit["checksum"],
          #   :repos => unit["repository_memberships"]
          # }
          result=search_rpm(name, repo)
          s = StringIO.new
          result.each do |r|
            s << "["<< r[:name] << "] : " << r[:version] << ", " << r[:release] << ", " << r[:repos] <<"\n"
          end
          response.reply s.string
        rescue StandardError => e
          response.reply e.message
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
          s = StringIO.new
          result.each do |r|
            s << "["<< r[:author] << "/" << r[:name]<< "] : " <<r[:version] << ", " << r[:repos] <<"\n"
          end
          response.reply s.string
        rescue StandardError => e
          response.reply e.message
        end
      end

      def copy_rpm(response)
         args = response.extensions[:kwargs]
         from = args[:from]
         to = args[:to]
         release = args[:release]
         name = args[:name]
         version = args[:version]
         arch = args[:arch]
         delete_newer=args[:delete_newer]||false
         publish=args[:publish]||false
         begin
           if from.nil? || to.nil? || release.nil? ||name.nil? || version.nil? || arch.nil?
             raise  "Exception: Missing required paramenter"
           end
           copy_rpm_between_repo!(from, to, name, version, release, arch, delete_newer, publish)
           response.reply "Command executed successfully"
         rescue StandardError => e
           response.reply e.message
         end
      end

      def copy_puppet(response)
        args = response.extensions[:kwargs]
        from = args[:from]
        to = args[:to]
        author = args[:author]
        name = args[:name]
        version = args[:version]
        delete_newer=args[:delete_newer]||false
        publish=args[:publish]||false
        begin
          if from.nil? || to.nil? || author.nil? || name.nil? || version.nil?
            raise "Exception: missing required parameters"
          end
          copy_puppet_between_repo!(from, to, author, name, version, delete_newer, publish)
          response.reply "Command executed successfully"
        rescue StandardError => e
          response.reply e.message
        end
      end

      def delete_newer_rpm(response)
        args = response.extensions[:kwargs]
        from = args[:from]
        release = args[:release]
        name = args[:name]
        version = args[:version]
        arch = args[:arch]
        publish=args[:publish]||false
        begin
          if from.nil? || author.nil? || name.nil? || version.nil?
            raise "Exception: missing required parameters"
          end
          delete_rpm_newer!(from, name, version, relase, arch, publish)
          response.reply "Command executed successfully"
        rescue StandardError => e
          response.reply e.message
        end
      end

      def delete_newer_puppet(response)
        args = response.extensions[:kwargs]
        from = args[:from]
        author = args[:author]
        name = args[:name]
        version = args[:version]
        publish=args[:publish]||false
        begin
          if from.nil? || author.nil? || name.nil? || version.nil?
            raise "Exception: missing required parameters"
          end
          delete_puppet_newer!(from, author, name, version, publish)
          response.reply "Command executed successfully"
        rescue StandardError => e
          response.reply e.message
        end
      end

      def cmd_create_rpm_repo(response)
        args = response.extensions[:kwargs]
        #puts "args: #{args}"
        repo_id = args[:repo_id]
        name = args[:name] || repo_id
        description = args[:description]
        feed = args[:feed]
        relative_url = args[:relative_url]
        serve_http = args[:http].nil? ? true : args[:http]
        serve_https = args[:https].nil? ? false : args[:https]
        auto_publish = args[:auto_publish].nil? ? false : args[:auto_publish]
        begin
          success = create_rpm_repo(repo_id: repo_id, display_name: name , description: description, feed_url: feed, relative_url: relative_url, serve_http: serve_http, serve_https: serve_https, auto_publish: auto_publish )
          response.reply "Repo created successfully."
        rescue Exception => e
          response.reply e.message
        end
      end

      Lita.register_handler(self)
      #Lita.register_hook(:trigger_route, Lita::Extensions::KeywordArguments)
    end
  end
end
