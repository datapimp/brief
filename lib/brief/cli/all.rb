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
  end
end

command 'info' do |c|
  c.syntax = 'brief info'
  c.description = 'View info about the brief environment'

  c.option '--print', 'Print output to the terminal'

  c.action do |args, options|
    if options.print
      # traveling ruby is reporting this incorrectly
      puts "\n-- Paths:"
      puts "Dir.pwd = #{ Dir.pwd }"
      puts "Brief.pwd = #{ Brief.pwd }"

      puts "\n-- Available apps:"
      puts Brief::Apps.available_apps.join("\n")
    else
      json = {
        version: Brief::VERSION,
        available_apps: Brief::Apps.available_apps,
        pwd: Brief.pwd
      }.to_json

      puts json
    end
  end
end
