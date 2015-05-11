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
        Brief::Server::Socket.new(root: options.root, websocket: ws)
      end
    }
  end
end
