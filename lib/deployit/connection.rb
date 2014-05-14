module Deployit
  class Connection
    attr_accessor :hostname, :port, :context_root, :admin_user, :admin_password, :ssl

    def initialize(args)
      args.each do |k,v|
        instance_variable_set("@#{k}", v) unless v.nil?
      end
    end

    def deployit_url
      "#{protocol}://#{admin_user}:#{admin_password}@#{hostname}:#{port}#{context_root}"
    end

    def protocol

      case ssl
        when true then "https"
        else "http"
      end

    end

    def reachable
      begin
        rest_get('/server/info')
        return true
      rescue
        return false
      end

    end

    def rest_get(service)
      RestClient.get URI::encode("#{deployit_url}/deployit/#{service}"), {:accept => :xml, :content_type => :xml }
    end

    def rest_post(service, body='')
      RestClient.post URI::encode("#{deployit_url}/deployit/#{service}"), body, {:content_type => :xml }
    end

    def rest_put(service, body)
      RestClient.put URI::encode("#{deployit_url}/deployit/#{service}"), body, {:content_type => :xml }
    end

    def rest_delete(service)
      RestClient.delete URI::encode("#{deployit_url}/deployit/#{service}"), {:accept => :xml, :content_type => :xml }
    end

  end
end