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

  def self.create_method_dispatcher_command_for(action, klass)
    identifier = "#{ action } #{ klass.type_alias.to_s.pluralize }"

    Object.class.class_eval do
      command "#{identifier}" do |c|
        c.syntax = "brief #{identifier}"
        c.description = "run the #{identifier} command"

        c.action do |args, _opts|
          briefcase = Brief.case

          path_args = args.select { |arg| arg.is_a?(String) && arg.match(/\.md$/) }

          path_args.select! do |arg|
            path = briefcase.repository.root.join(arg)
            path.exist?
          end

          path_args.map! { |p| briefcase.repository.root.join(p) }

          models = path_args.map { |path| Brief::Document.new(path) }.map(&:to_model)

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
