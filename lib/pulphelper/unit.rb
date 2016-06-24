require 'json'
module PulpHelper
  module Unit
    def search_rpm(name, repo)
      criteria = {
        "fields" => ["name", "version", "release", "epoch"],
        "filters" => {
          "name" => {
            "$regex" => name
          }
        },
        "sort" => [["name", "descending"], ["version", "descending"], ["epoch", "descending"], ["release", "descending"]]
      }
      puts "search criteria #{criteria}"
      response = client.resources.unit.search("rpm", criteria, {"include_repos" => true})
      code = response.code
      body = response.body
      puts body
      results =[]
      case code
      when 200
        units = JSON.parse(body.to_json)
        units.each do |unit|
          result => {
            :name => unit["name"],
            :epoch => unit["epoch"],
            :version => unit["version"],
            :release => unit["release"],
            :repos => unit["repo_associated"]
          }
          results << result
        end
      else
        puts "response code = #{code}"
      end
      #filter by repo
      if repo
        results =results.select {|r| 
          r[:repos].include? repo
        }
      end
      results
    end # end search 
    def search_puppet(name, repo)
      criteria = {
        "fields" => ["name", "version", "author"],
        "filters" => {
          "name" => {
            "$regex" => name
          }
        },
        "sort" => [["name", "descending"], ["version", "descending"]]
      }
      puts "search criteria #{criteria}"
      response = client.resources.unit.search("rpm", criteria, {"include_repos" => true})
      code = response.code
      body = response.body
      puts body
      results =[]
      case code
      when 200
        units = JSON.parse(body.to_json)
        units.each do |unit|
          result => {
            :name => unit["name"],
            :version => unit["version"],
            :author => unit["author"],
            :repos => unit["repo_associated"]
          }
          results << result
        end
      else
        puts "response code = #{code}"
      end
      #filter by repo
      if repo
        results =results.select {|r| 
          r[:repos].include? repo
        }
      end
      results
    end

    def copy_rpm(from, to, name, version, release, delete_newer)
    end

    def copy_puppet(from, to, name, author, version, delete_newer)
    end
  end
end
