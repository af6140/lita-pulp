require 'runcible'

module PulpHelper
  module User

    def create_user(username, password)
      response = client.resources.user.create(username, :name => username, :password => password)
      if response.code == 201
        "User created."
      else
        raise "Failed to create user, response code: #{response.code}"
      end
    end

    def get_user(username)
      response = client.resources.retrive(username)
      if response.code == 200
        response.body
      else
        raise "Failed to retrieve user, response code #{response.code}"
      end
    end

    def delete_user(username)
      response = client.resources.delete(username)
      if response.code == 200
        response.body
      else
        raise "Failed to delete user, response code #{response.code}"
      end
    end

    def change_password(password)

    end

    def assign_role(user, role)
      response = client.resources.add(role, user)
      if response.code == 200
        response.body
      else
        raise "Failed to assign role to user, response code #{response.code}"
      end
    end

    def unassign_role(user, role)
      response = client.resources.remove(role, user)
      if response.code == 200
        response.body
      else
        raise "Failed to unassign role from user, response code #{response.code}"
      end
    end

  end
end