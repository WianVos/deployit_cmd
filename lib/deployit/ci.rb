module Deployit
  class Ci

    attr_accessor :id, :type, :properties, :persisted

    extend Mixins::Xml


    #instance methods
    def initialize(args)
      # initilize an empty properties hash
      @properties = {}

      # loop over the given arguments and act accordingly
      args.each do |k,v|
        if ['id', 'type'].include? k
          instance_variable_set("@#{k}", v) unless v.nil?
        else
          @properties.merge!({ "#{k}" => "#{v}" })
        end
      end

      @persisted = false

      if exists?
        @properties.merge! persisted_properties
        @properties.delete('id')
        @type = persisted_type
        @persisted = true
      end

    end

    def to_hash
      new_hash = {}
      new_hash[id] = properties.merge({'type' => "#{type}"})
      return new_hash
    end

    def xml
      Deployit.connection.rest_get "repository/ci/#{id}"
    end

    def persisted_properties
      self.class.to_hash(xml)
    end

    def persisted_type
      self.class.root_element(xml)
    end


    # get all the children of this ci
    def children
      self.class.cis_from_query("&parent=#{id}")
    end

    def all_children
      all_children = children
      children.each {|c| c.all_children.each {|a| all_children << a } unless c.all_children.empty? }
      return all_children
    end

    def all_children_by_type(type)
      all_children.select {|c| type == c.type }
    end

    def exists?
      begin
        Deployit.connection.rest_get "repository/ci/#{id}"
        return true
      rescue
        return false
      end
    end

    def update
      ci_xml = to_xml(id,type,properties)
      if exists?
        Deployit.connection.rest_post "repository/ci/#{id}", ci_xml
      else
        Deployit.connection.rest_put "repository/ci/#{id}", ci_xml
      end

    end

    #class methods

    def self.cis_from_query(query_string)
    cis = []
    to_hash(Deployit.connection.rest_get "repository/query?resultsPerPage=-1#{query_string}").each do |c|
      if c.class == Array
        c.each do |ci|
          if ci.class == Array
            ci.each do |ds|
              if ds.class == Hash
                new_ci = Deployit::Ci.new({'id' => ds["ref"], 'type' =>  ds["type"]})
              end
            end
          elsif ci.class == Hash
            new_ci = Deployit::Ci.new({'id' => ci["ref"], 'type' =>  ci["type"]})
          end
            cis << new_ci unless new_ci.nil?
          end
        end
        return cis
      end
    end

    def self.cis
      cis_from_query(nil)
    end

    def self.list(filter = '*')
      cis.collect {|ci| ci.id if ci.id =~ /#{filter}/ }
    end

    

  end
end