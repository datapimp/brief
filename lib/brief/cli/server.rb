command 'start gateway server' do |c|
  c.option '--host HOSTNAME', nil, 'What hostname to listen on'
  c.option '--port PORT', nil, 'What port to listen on'

  c.action do |args, options|
    options.default(root: Brief.pwd, port: 9094, host: '0.0.0.0')

    require 'thin'
    require 'rack/handler/thin'
    require 'brief/server/gateway'
    Brief::Server::Gateway.start(port: options.port, host: options.host, root: Pathname(options.root))
  end
end

command 'start socket server' do |c|
  c.option '--port PORT', String, 'What port to listen on'

  c.action do |args, options|
    options.default(root: Brief.pwd, port: 5054)

    require 'brief/server/socket'
    require 'em-websocket'


    EM.run {
      EM::WebSocket.run(:host=>"0.0.0.0",:port => 8089) do |ws|

        socket = Brief::Server::Socket.new(root: options.root)

        ws.onopen do |handshake|
          ws.send ({:briefcases=> socket.briefcases.keys}.to_json)
        end

        ws.onmessage do |raw|
          if message = (JSON.parse(raw) rescue nil)
            socket.receive(message, ws)
          end
        end
      end
    }
  end
end

command 'start drb server' do |c|
  c.option '--host HOSTNAME', String, 'What hostname to listen on'
  c.option '--port PORT', String, 'What port to listen on'
  c.option '--gateway', 'Create a gateway instead of a briefcase'

  c.action do |args, options|
    options.default(root: Brief.pwd)

    require 'drb'

    root = Pathname(options.root)

    object = if options.gateway
               Brief::Server::Distributed.new(root: root, briefcase_options: {eager: true})
             else
               Brief::Briefcase.new(root: root, eager: true)
             end

    puts "== starting distributed service"
    DRb.start_service "druby://:#{ options.port || 9000 }", object
    trap("INT") { DRb.stop_service }
    DRb.thread.join()
  end
end
