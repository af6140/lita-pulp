require 'json'
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
            :description => repo["description"],
            :content_unit_counts => repo["content_unit_counts"],
            :url => repo["_href"],
          }
          #puts repo_data
          result << repo_data
        end
      else
        puts "code=#{code}"
      end
      return result
    end
  end
end
