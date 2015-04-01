class Brief::Server::Socket
  def self.start(options={}, &block)
    require 'em-websocket' unless defined?(EM::WebSocket)

    host = options.fetch(:host, '0.0.0.0')
    host = options.fetch(:port, '8023')

    gateway = Brief::Server::Gateway.new(options)

    socket = new(gateway: gateway)

    EM.run {
      socket.start
    }
  end

  attr_reader :gateway,
              :options,
              :host,
              :port

  def initialize(options={})
    @options = options
    @gateway = gateway
    @host    = options.fetch(:host, '0.0.0.0')
    @port    = options.fetch(:port, 9099)
  end

  def log(message)
    if options[:log_to_console]
      puts(message)
    end
  end

  def start
    log "Starting socket gateway: #{port} host: #{ host }"
    EM::WebSocket.run(:host => host, :port => port) do |ws|
      ws.onopen do |handshake|
        log("== Brief client connected")
        log(handshake.inspect)
      end

      ws.onclose do
        log("brief Connection closed")
      end

      ws.onmessage do |data|
         message = OpenStruct.new(JSON.parse(data))
         log "== Websocket Command: #{ message }"
      end
    end
  end
end
