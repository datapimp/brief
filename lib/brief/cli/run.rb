command "run command" do |c|
  c.syntax = 'brief run FILE'
  c.description = 'run a script in the context of the briefcase'

  c.option '--root PATH', String, 'The briefcase root'

  c.action do |args, options|
    options.default(root: Pathname(args.first || Brief.pwd))

    command = args.first.to_s.to_sym

    bc = Brief.case = Brief::Briefcase.new(root: Pathname(options.root))
    bc = bc.call if bc.respond_to?(:call)

    if !Brief.commands[command.to_sym]
      puts "Invalid command. #{ Brief.commands.keys }"
    else
      bc.run_command(command.to_sym, *args)
    end
  end
end

command "run" do |c|
  c.syntax = 'brief run FILE'
  c.description = 'run a script in the context of the briefcase'

  c.action do |args, options|
    code = Pathname(args.first).read
    Brief.case.instance_eval(code)
  end
end
