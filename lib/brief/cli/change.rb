command 'change' do |c|
  c.syntax = 'brief change ATTRIBUTE [OPTIONS]'
  c.description = 'change attributes of brief documents'

  c.option '--from', String, 'Only apply when the attributes current value matches.'
  c.option '--to', String, 'Only apply when the attributes current value matches.'
  c.option '--files', String, 'The files you want to change'
  c.option '--on', String, 'alias for --files. The files you want to change'

  c.action do |args, options|
    puts "Args: #{ args.inspect }"
    puts "Options: #{ options.inspect }"
  end
end
