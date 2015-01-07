module Brief::Util
  def self.create_method_dispatcher_command_for(action, klass)
    identifier = "#{ action } #{ klass.type_alias.to_s.pluralize }"

    Object.class.class_eval do
      command "#{identifier}" do |c|
        c.syntax = "brief #{identifier}"
        c.description = "run the #{identifier} command"

        c.action do |args, opts|
          briefcase = Brief.case

          path_args = args.select {|arg| arg.is_a?(String) && arg.match(/\.md$/) }

          path_args.select! do |arg|
            path = briefcase.repository.root.join(arg)
            path.exist?
          end

          path_args.map! {|p| briefcase.repository.root.join(p) }

          models = path_args.map {|path| Brief::Document.new(path) }.map(&:to_model)

          if models.empty?
            model_finder = c.name.to_s.split(' ').last
            models = briefcase.send(model_finder)
          end

          models.each do |model|
            model.send(action)
          end
        end
      end rescue nil
    end
  end
end
