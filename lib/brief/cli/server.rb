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

command 'start socket gateway' do |c|
  c.option '--host HOSTNAME', String, 'What hostname to listen on'
  c.option '--port PORT', String, 'What port to listen on'

  c.action do |args, options|
    options.default(root: Brief.pwd)

    require 'em-websocket'
    require 'brief/server/gateway'
    require 'brief/server/socket'
    Brief::Server::Socket.start(port: options.port, host: options.host, root: Pathname(options.root))
  end
end
