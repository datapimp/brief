command 'change' do |c|
  c.syntax = 'brief change ATTRIBUTE [OPTIONS]'
  c.description = 'change attributes of brief documents'

  c.option '--from', String, 'Only apply when the attributes current value matches.'
  c.option '--to', String, 'Only apply when the attributes current value matches.'
  c.option '--files', String, 'The files you want to change'
  c.option '--on', String, 'alias for --files. The files you want to change'

  c.action do |args, options|
    # TODO
    # Implement
    #
    # Should be able to use the Dir[docs_path.join(whatever)]
    # to support a wide range of file inputs
  end
end

command 'init' do |c|
  c.syntax = 'brief init NAME [OPTIONS]'
  c.description = 'Create a new brief project, aka a briefcase'

  c.option '--root', String, 'The root folder for the new project.'

  c.action do |args, options|
    # TODO
    # Implement
  end
end
command 'info' do |c|
  c.syntax = 'brief info'
  c.description = 'View info about the brief environment'

  c.action do |args, options|
    # traveling ruby is reporting this incorrectly
    puts "Dir.pwd = #{ Dir.pwd }"
    puts "Brief.pwd = #{ Brief.pwd }"

    puts "\n\n-- Available apps:"
    puts Brief::Apps.available_apps.join("\n")
  end
end
