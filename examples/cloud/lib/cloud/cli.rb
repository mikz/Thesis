require 'fog'
require 'thor'
require 'socket'

module Cloud

  class CLI < Thor
    desc "create IMAGE_ID", "create new server on EC2 from IMAGE_ID"

    method_option :type, default: "t1.micro", desc: "Specify how big instance should be created", type: :string
    method_option :key, default: Socket.gethostname, desc: "Specify which key pair should be used for instance", type: :string

    def create(image_id)
      server = connection.servers.create image_id: image_id, flavor_id: options[:type], key_name: options[:key]
      server.wait_for { print "."; ready? }
      say "started #{image_id} #{server.flavor_id} instance #=> id: #{server.id}, dns: #{server.dns_name}"
    end

    desc "list", "list all EC2 servers"
    def list
      servers = connection.servers.all
      return say "No servers found" unless servers.any?

      servers.each do |server|
        say "#{server.id}\t#{server.dns_name}\t#{server.image_id}\t#{server.flavor_id}"
      end
    end

    desc "destroy ID", "destroy server with ID"
    def destroy(id)
      server = connection.servers.get(id)
      return say "No server with id #{id} found" unless server

      server.destroy
      say "Server #{id} will be destroyed in a minute"
    end

    private

    def connection
      @connection ||= Fog::Compute::AWS.new(
        aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
        aws_access_key_id:     ENV['AWS_ACCESS_KEY_ID'],
        region:                'eu-west-1'
      )
    end
  end

end
