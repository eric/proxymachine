module EventMachine
  module Protocols
    class ServerConnection < Connection
      def self.request(host, port, client_side)
        EventMachine.connect(host, port, self, client_side)
      end

      def initialize(conn)
        @client_side = conn
      end

      def post_init
        if ProxyMachine.server_filter
          @buffer = []
        else
          proxy_incoming_to @client_side
        end
      end

      def receive_data(data)
        @buffer << data

        process_server_side_response
      end

      def process_server_side_response
        commands = ProxyMachine.server_filter.call(@buffer.join)
        close_connection unless commands.instance_of?(Hash)
        if proxy = commands[:proxy]
          @client_side.send_data(proxy)
          @buffer = []
          proxy_incoming_to @client_side
        elsif commands[:noop]
          # do nothing
        else
          close_connection
        end
      end

      def unbind
        @client_side.close_connection_after_writing
      end
    end
  end
end
