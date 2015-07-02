module Brief::Util
  def self.ensure_child_path(root, testpath)
    root = Pathname(root).realpath.to_s.downcase
    testpath = Pathname(testpath).parent.realpath.to_s.downcase

    outside = !!(root.split("/").length > testpath.split("/").length)

    if !outside && testpath.match(/^#{root}/)
      return true
    end

    false
  end

  def self.split_doc_content(raw_content)
    if raw_content =~ /^(---\s*\n.*?\n?)^(---\s*$\n?)/m
      content = raw_content[(Regexp.last_match[1].size + Regexp.last_match[2].size)..-1]
      frontmatter = YAML.load(Regexp.last_match[1]).to_mash
      [content, frontmatter]
    else
      [nil, {}.to_mash]
    end
  end

  def self.create_singular_method_dispatcher_command_for(action, klass)
    identifier = "#{ action } #{ klass.type_alias }"

    Object.class.class_eval do
      command "#{identifier}" do |c|
        c.syntax = "brief #{identifier} PATH"
        c.description = "run the #{identifier} command on the model specified at path"

        c.action do |args, _opts|
          briefcase = $briefcase || Brief.case

          path_args = args.select { |arg| arg.is_a?(String) && arg.match(/\.md$/) }

          path_args.select! do |arg|
            briefcase.root.join(arg).exist?
          end

          path_args.map! { |p| briefcase.root.join(p) }

          models = briefcase.documents_at(*path_args).map(&:to_model)

          if models.empty?
            model_finder = c.name.to_s.split(' ').last
            models = briefcase.send(model_finder)
          elsif models.length > 1
            puts "You passed more than one model.  If this is what you want, use the pluralized version of this command to be safe"
          else
            model = models.first
            model && model.send(action)
          end
        end
      end rescue nil
    end
  end

  # takes the actions from the models and creates a command
  # that lets you dispatch the action to a group of models at the
  # paths / directory / glob you pass
  def self.create_method_dispatcher_command_for(action, klass)
    create_singular_method_dispatcher_command_for(action,klass)

    identifier = "#{ action } #{ klass.type_alias.to_s.pluralize }"

    Object.class.class_eval do
      command "#{identifier}" do |c|
        c.syntax = "brief #{identifier} PATHS"
        c.description = "run the #{identifier} command on the models at PATHS"

        c.action do |args, _opts|
          briefcase = $briefcase || Brief.case

          path_args = args.select { |arg| arg.is_a?(String) && arg.match(/\.md$/) }

          path_args.select! do |arg|
            briefcase.root.join(arg).exist?
          end

          path_args.map! { |p| briefcase.root.join(p) }

          models = briefcase.documents_at(*path_args).map(&:to_model)

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
