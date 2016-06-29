require 'json'
require 'runcible'

module PulpHelper
  module Repo
    REPO_TYPE_RPM="rpm-repo"
    REPO_TYPE_PUPPET="puppet-repo"

    def list_repo(type)
      criteria = {
        "filters" => {
          "notes._repo-type" => {
            "$in" => [type]
          }
        }
      }
      #puts "criteria:#{criteria}"
      response=client.resources.repository.search(criteria)
      code=response.code
      body=response.body
      result=[]
      case code
      when 200
        repos=JSON.parse(body.to_json)
        #puts repos
        repos.each do |repo|
            repo_data={
              :id => repo["id"],
              :name => repo["display_name"],
              :description => repo["description"]
            }
            #puts repos
            result << repo_data
        end
      else
        raise "Exception: cannot list repository: response code :#{code}"
      end
      return result
    end#list_repo

    #yum repo
    # distributors
    #   distributor_type_id : yum_distributor
    #     auto_publish: true or false
    #     last_publish:
    #     config:
    #       http:
    #       https:
    #       relative_url
    # importers
    #    importer_type_id:  yum_importer
    #    last_sync:
    #    config:
    #      feed

    #puppet repo
    # distributors:
    #  distributor_type_id: "puppet_distributor"
    #    auto_publish:
    #    last_publish
    #    config :
    # importers:
    #   importer_type_id: "puppet_importer"
    def list_repo_details(type)
      criteria = {
        "filters" => {
          "notes._repo-type" => {
            "$in" => [type]
          }
        }
      }
      #puts "criteria:#{criteria}"
      response=client.resources.repository.search(criteria, {"details" => true})
      code=response.code
      body=response.body
      result=[]
      case code
      when 200
        repos=JSON.parse(body.to_json)
        #puts repos
        repos.each do |repo|
          case type
          when REPO_TYPE_RPM
            yum_distributor = repo["distributors"].select{ |d| d["distributor_type_id"] == 'yum_distributor'}[0]
            yum_importer = repo["distributors"].select{ |d| d["distributor_type_id"] == 'yum_importer'}[0]

            distributor = nil
            if  yum_distributor
              distributor = {
                :auto_publish => yum_distributor["auto_publish"],
                :last_publish => yum_distributor["last_publish"],
                :config => yum_distributor["config"]
              }
            end
            importer = nil
            if yum_importer
              importer = {
                :last_sync => yum_importer["last_sync"],
                :config => yum_importer["config"]
              }
            end

            repo_data={
              :id => repo["id"],
              :name => repo["display_name"],
              :description => repo["description"],
              :content_unit_counts => repo["content_unit_counts"],
              :type => REPO_TYPE_RPM,
              :distributor => distributor,
              :importer => importer,
            }
            #puts repos
            result << repo_data
          when REPO_TYPE_PUPPET
            puppet_distributor = repo["distributors"].select{ |d| d["distributor_type_id"] == 'puppet_distributor'}[0]
            distributor =nil
            if puppet_distributor
              distributor = {
                :auto_publish => yum_distributor["auto_publish"],
                :last_publish => yum_distributor["last_publish"],
                :config => yum_distributor["config"]
              }
            end
            repo_data={
              :id => repo["id"],
              :name => repo["display_name"],
              :description => repo["description"],
              :content_unit_counts => repo["content_unit_counts"],
              :type => REPO_TYPE_PUPPET,
              :distributor => distributor
            }
            #puts repos
            result << repo_data
          else
          end
        end
      else
        raise "Exception: cannot list repository: response code :#{code}"
      end
      return result
    end#list_repo_details

    def publish_repo!(forge_id)
      message = "Publish #{forge_id} submitted successfully"
      begin
        publish_response=client.extensions.repository.publish_all(forge_id)

        ##
        ## Runcilbe does not proper include respone code
        ##
        if publish_response.code !=202 && !"#{publish_response.code}".start_with?("20")
          raise "Publish #{forge_id} failed with http response code: #{publish_response.code}"
        end
      rescue StandardError => e
        raise "Excpetion: Failed to publish, #{e.message}"
      end
    end#publish_repo

    def delete_rpm_newer!(forge_id, name, version, release, arch, auto_publish=false)
      criteria = get_rpm_unit_ass_criteria(name, version, release, arch)
      begin
        unassociate_response=client.resources.repository.unassociate_units(forge_id, criteria)
        #pulp api documented response code
        if unassociate_response.code !=202
          raise "Exception: cannot unassociate unit, response code: #{unassociate_response.code}"
        end
        if auto_publish
          publish_response=client.extensions.repository.publish_all(forge_id)
          presponse=JSON.parse(publish_response.to_json)
          if presponse.nil? || presponse[0]["spawned_tasks"].length<1
            raise "Exception: repo publish requeste failed, response : #{publish_response}"
          end

          # if publish_response.code !=202 && !"#{publish_response.code}".start_with?("20")
          #    raise "Exception: repo publish requeste failed, response code : #{publish_response.code}"
          # end
        end
      rescue StandardError => e
        raise "Error delete rpm pakcage older than #{name}-#{version}-#{release} from repo #{forge_id}: #{e.message}"
      end
    end#delete_rpm_newer

    def copy_rpm_between_repo!(from_repo, to_repo, name, version, release, arch, delete_new=false, auto_publish=true)
      search_params=get_rpm_search_params(name, version, release, arch)
      begin
        unit_search_response=client.resources.unit.search('rpm', search_params[:criteria], search_params[:optional])

        if unit_search_response.code !=200
          raise "Exception: Cannot find unit"
        end
        found_units=JSON.parse(unit_search_response.to_json)
        unit_id=found_units.first['_id']

        copy_unit_ids= {
            :ids => [unit_id]
        }
        copy_response=client.extensions.rpm.copy(from_repo, to_repo, copy_unit_ids)
        if copy_response.code !=200 && copy_response.code !=202
          raise "Exception: unit copy failed with code #{copy_response.code}"
        end

        if(delete_new)
          delete_rpm_newer!(to_repo, name, version, release, arch,  auto_publish)
        end
      rescue StandardError => e
        raise "Exception: Error copy module between repo: #{e.to_s}"
      end
    end#copy_rpm_between_repo

    def delete_puppet_newer!(forge_id, author, name, version, auto_publish=false)
      #/pulp/api/v2/repositories/<repo_id>/actions/unassociate/
      criteria = get_puppet_unit_assoc_criteria(author, name, version)
      begin
        unassociate_response=client.resources.repository.unassociate_units(forge_id, criteria)
        #pulp api documented response code
        if unassociate_response.code !=202
          raise "Exception: cannot unassociate unit, response code: #{unassociate_response.code}"
        end
        if auto_publish
          publish_response=client.extensions.repository.publish_all(forge_id)

          presponse=JSON.parse(publish_response.to_json)
          if presponse.nil? || presponse[0]["spawned_tasks"].length<1
            raise "Exception: repo publish requeste failed, response : #{publish_response}"
          end
          # if publish_response.code !=202 && !"#{publish_response.code}".start_with?("20")
          #    raise "Exception: repo publish requeste failed, response code : #{publish_response.code}"
          # end
        end
      rescue StandardError => e
        raise "Exception: Error delete module newer than #{author}-#{name}-#{version} from repo #{forge_id}: #{e.message}"
      end
    end#function

    def copy_puppet_between_repo!(from_repo, to_repo, author,name, version, delete_new=false, auto_publish=true)
      search_params = get_puppet_search_params(author, name, version)
      begin
        puts "search_params :#{search_params}"
        unit_search_response=client.resources.unit.search("puppet_module", search_params[:criteria], search_params[:optional])
        if unit_search_response.code !=200
          raise "Exception: unit search faild with code #{unit_search_response.code}"
        end
        puts "search_response : #{unit_search_response.to_json}"
        found_units=JSON.parse(unit_search_response.to_json)
        unit_id=found_units.first['_id']

        unless unit_id && unit_id.length >0
          raise "No puppet module found to copy"
        end
        copy_unit_ids= {
            :ids => [unit_id]
        }
        copy_response=client.extensions.puppet_module.copy(from_repo, to_repo, copy_unit_ids)
        if copy_response.code !=200 && copy_response.code !=202
          raise "Exception: unit copy failed with code #{copy_response.code}"
        end
        if(delete_new)
          delete_puppet_newer!(to_repo,author, name, version, auto_publish )
        end
      rescue StandardError => e
        raise "Error copy module between repo: #{e.to_s}"
      end
    end# copy puppet


    private
    def get_rpm_search_params (name, version, release, arch)
      search_optional= {
          :include_repos => true
      }
      search_criteria ={
        :filters => {
            :name => name,
            :version=> version,
            :release => release,
            :arch => arch,
        },
        :sort => [["version", "descending"]],
        :limit => 1,
        :fields => ["name", "version", "release", "arch"]
      }

      search_params= {
        :optional => search_optional,
        :criteria => search_criteria,
      }

      return search_params
    end# get_rpm_search_params

    def get_rpm_unit_ass_criteria(name, version, release, arch)
       #/pulp/api/v2/repositories/<repo_id>/actions/unassociate/
      criteria= {
        :filters => {
            :unit => {
              '$and' => [
                  {:name => name},
                  {:arch => arch},
                  '$or' => [
                    :version=> {
                      '$gt' => version
                    },
                    :release => {
                      '$gt' => release
                    }
                  ]
              ]
            }
        },
        :type_ids => ["rpm"]
      }

      return criteria
    end#function

    def get_puppet_search_params(author, name, version)
      search_optional= {
          :include_repos => true
      }
      search_criteria ={
        :filters => {
            :author => author,
            :name => name,
            :version=> version
        },
        :sort => [["version", "descending"]],
        :limit => 1,
        :fields => ["author", "name", "version"]
      }

      search_params={
        :criteria =>  search_criteria,
        :optional => search_optional,
      }

      return search_params
    end#function
    def get_puppet_unit_assoc_criteria(author, name, version)
       criteria= {
        :filters => {
            :unit => {
              '$and' => [
                  {:name => name},
                  {:author => author},
                  :version=> {
                    '$gt' => version
                  }
              ]
            }
        },
        :type_ids => ["puppet_module"]
      }
      return criteria
    end#function
  end#module
end#module
