module Deployit
  class Server



    attr_accessor :hostname, :port, :context_root, :admin_user, :admin_password, :ssl

    def initialize(args)

      extend Mixins::Xml

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
        resource_exists?('/Infrastructure')
        return true
      rescue
        return false
      end

    end

    def cis_from_query(query_string)
      cis = []
      to_hash(rest_get "repository/query?resultsPerPage=-1#{query_string}").each do |c|
        if c.class == Array
          c.each do |ci|
           if ci.class == Array
             ci.each do |ds|
               if ds.class == Hash
                 new_ci = Deployit::Ci.new({:id => ds["@ref"], :type =>  ds["@type"], :server => self })
                 cis << new_ci
               end
             end
           end
          end
        end
      end
      return cis
    end

    def cis
      cis_from_query(nil)
    end

    def get_ci(id)
      cis.select {|ci| id == ci.id}.first
    end

    def get_ci_properties(ci_id)
      to_hash(rest_get "repository/ci/#{ci_id}")
    end

    # get a hash with all the ci properties
    # {'ci_id' => { 'prop1' => 'value'}}
    # this is kinda a big operation .. be carefull about using
    def get_cis_with_properties
      Hash[cis.collect {|x| [x.id, x.properties ]}]
    end

    # get all cis that have a certian property set to a certain value
    def get_cis_by_property_value(property, value)
      get_cis_with_properties.select {|id, hash| hash.has_key? property and hash[property] == value }
    end




    def method_missing(meth, *args, &block)
      if meth.to_s =~ /^find_ci_by(.+)$/
        run_find_ci_by_method(meth, *args, &block)
      else
        super # You *must* call super if you don't handle the
        # method, otherwise you'll mess up Ruby's method
        # lookup.
      end
    end

    def respond_to?(meth)
      if meth.to_s =~ /^find_ci_by.*$/
        true
      else
        super
      end
    end

    def run_find_ci_by_method(meth, *args, &block)
      #get the property to find the ci by
      args_array = meth.to_s.split('_')
      # get the first search argument into a hash or return a error
      # .. this wil be the fourth element to our array and the first argument given
      search_hash = {'or' => { args_array[3] => args[0]} }

      # now determine if this is an AND or an OR search
      # to do this we have to look at the fifth field of the array
      if args_array[5].nil? == false
        raise "illegal operand: Expecting AND or OR" unless args_array[4].in ['and', 'or']
        raise "unable to find argument to march #{args_array[5]}" if args[1].nil?
        search_hash.new = { args_array[4] => {args_array[5] => args[1]}}
      end

      # initialize a results hash
      results = {}
      # now loop over the search hash and get all the AND's and merge
      search_hash.each do |type, search|
        if type == 'or'
          property = search.keys[0]
          value = search.values[0]
          results.merge! get_cis_by_property_value(property, value)
        else type == 'and'
          property = search.keys[0]
          value = search.values[0]
          results.select {|id, hash| hash.has_key? property and hash[property] == value }
        end
      end
      return results
    end

    private
    
    def resource_exists?(id)
      # check if a certain resource exists in the deployit repository
      xml = rest_get "repository/exists/#{id}"
      return to_hash(xml) == "true"
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