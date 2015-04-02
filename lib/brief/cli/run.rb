command "run" do |c|
  c.syntax = 'brief run FILE'
  c.description = 'run a script in the context of the briefcase'

  c.action do |args, options|
    code = Pathname(args.first).read
    Brief.case.instance_eval(code)
  end
end
