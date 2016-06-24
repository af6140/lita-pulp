require 'json'
module PulpHelper
  module Unit
    def search_rpm(name, repo)
      criteria = {
        "fields" => ["name", "version", "release", "epoch", "checksum"],
        "filters" => {
          "name" => {
            "$regex" => name
          }
        },
        "sort" => [["epoch", "descending"], ["version", "descending"],  ["release", "descending"]]
      }
      puts "search criteria #{criteria} in repo : #{repo}"
      response = client.resources.unit.search("rpm", criteria, {"include_repos" => true})
      code = response.code
      body = response.body
      puts body
      results =[]
      case code
      when 200
        units = JSON.parse(body.to_json)
        units.each do |unit|
          result = {
            :name => unit["name"],
            :epoch => unit["epoch"],
            :version => unit["version"],
            :release => unit["release"],
            :checksum =>  unit["checksum"],
            :repos => unit["repository_memberships"]
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
      puts "result:#{results}"
      results
    end # end search
    def search_puppet(author, name, repo)
      if author.nil?
        criteria = {
          "fields" => ["author","name", "version"],
          "filters" => {
            "name" => {
              "$regex" => name
            }
          },
          "sort" => [["author", "descending"],["name", "descending"],["version", "descending"]]
        }
      else
        criteria = {
          "fields" => ["author","name", "version"],
          "filters" => {
            "$and" => [
              {
                "name" => {
                  "$regex" => name
                }
              },
              {
                "author" => author
              }
            ]
          },
          "sort" => [["author", "descending"],["name", "descending"],["version", "descending"]]
        }
      end
      puts "search criteria #{criteria}"
      response = client.resources.unit.search("puppet_module", criteria, {"include_repos" => true})
      code = response.code
      body = response.body
      #puts body
      results =[]
      case code
      when 200
        units = JSON.parse(body.to_json)
        units.each do |unit|
          result ={
            :name => unit["name"],
            :version => unit["version"],
            :author => unit["author"],
            :repos => unit["repository_memberships"]
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
      puts results
      results
    end

    def copy_rpm(from, to, name, version, release, delete_newer)
    end

    def copy_puppet(from, to, name, author, version, delete_newer)
    end
  end
end
