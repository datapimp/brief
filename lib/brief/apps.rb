module Brief
  class Apps
    def self.default_path
      Brief.gem_root.join("..","apps")
    end

    def self.search_paths
      paths = [default_path]

      if custom_path = ENV['BRIEF_APPS_PATH']
        custom_path = custom_path.to_s.to_pathname
        paths << custom_path if (custom_path.exist? rescue nil)
      end

      paths
    end

    def self.app_paths
      search_paths.map do |base|
        base.children.select do |child|
          child.join("config.rb").exist?
        end
      end.flatten
    end

    def self.available?(app_name)
      available_apps.include?(app_name.to_s)
    end

    def self.path_for(app_name)
      app_paths.detect {|b| b.basename.to_s == app_name }
    end

    def self.available_apps
      app_paths.map(&:basename).map(&:to_s)
    end

    def self.create_namespaces
      available_apps.map(&:camelize).each do |namespace|
        const_set(namespace, Module.new)
      end
    end

    def self.find_namespace(app_name)
      Brief::Apps.const_get(app_name.to_s.camelize)
    end
  end
end
