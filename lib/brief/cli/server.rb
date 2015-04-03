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
