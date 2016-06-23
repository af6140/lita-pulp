require 'json'
module PulpHelper
  module Unit
    def search_rpm(name)
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
      case code
      when 200
      else
        puts "response code = #{code}"
      end
    end
  end
end
