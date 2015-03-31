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

command 'start gateway server' do |c|
  c.option '--host HOSTNAME', String, 'What hostname to listen on'
  c.option '--port PORT', String, 'What port to listen on'

  c.action do |args, options|
    options.default(root: Brief.pwd)

    require 'thin'
    require 'brief/server/gateway'
    Brief::Server::Gateway.start(port: options.port, host: options.host, root: Pathname(options.root))
  end
end

command 'change' do |c|
  c.syntax = 'brief change ATTRIBUTE [OPTIONS]'
  c.description = 'change attributes of brief documents'

  c.option '--from VALUE', String, 'Only apply when the attributes current value matches.'
  c.option '--to VALUE', String, 'Only apply when the attributes current value matches.'
  c.option '--root PATH', String, 'The root directory for the briefcase'
  c.option '--operator VALUE', String, 'What operator to use in matching the from value. (eq,neq,gt,gte,lt,lte). defaults: eq'
  c.option '--dry-run', nil, "Don't actually save"

  c.action do |args, options|
    options.default(root: Pathname(Brief.pwd), operator: "eq")
    attribute = args.shift
    paths     = args.map {|a| Dir[options.root.join(a)] }.flatten

    briefcase = Brief::Briefcase.new(root: options.root)
    documents = briefcase.documents_at(*paths)

    if options.from
      #attribute = attribute.to_sym.send(options.operator)
      attribute = attribute.to_sym
      documents = Brief::DocumentMapper::Query.new(documents).where({attribute => options.from}).all
    end

    if documents.length == 0
      puts "No documents match this selection"
    end

    if options.dry_run
      puts documents
    end

    documents
  end
end

command 'init' do |c|
  c.syntax = 'brief init NAME [OPTIONS]'
  c.description = 'Create a new brief project, aka a briefcase'

  c.option '--root', String, 'The root folder for the new project.'
  c.option '--app', String, 'Which existing app would you like to use?'

  c.action do |args, options|
    options.default :root => (args.first || Brief.pwd)

    root = Pathname(options.root)

    if root.join('brief.rb').exist?
      puts "A Brief project already exists in this folder"
    else
      require 'brief/briefcase/initializer'
      Brief::Briefcase.create_new_briefcase(root: root, app: options.app)
    end

    false
  end
end
