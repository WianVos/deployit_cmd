require 'active_attr'
require 'rest-client'
require 'xmlsimple'
require 'open-uri'
require 'nokogiri'

require 'deployit/mixins/xml'
require 'deployit/mixins/connection'
require 'deployit/server'
require 'deployit/ci'



module Deployit

  autoload :Ci,         'deployit/ci'
  autoload :Connection, 'deployit/connection'

  extend Mixins::Connection




end