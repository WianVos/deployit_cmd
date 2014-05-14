module Deployit
  module Mixins
    module Connection

      def connect(args)
        @connection = Deployit::Connection.new(args)

        return @connection
      end

      def connection
        return @connection
      end

      def connected?
        return false if @connection.nil?
        return true
      end

    end
  end
end