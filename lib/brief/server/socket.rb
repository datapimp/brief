module Brief
  class Server
    class Socket
      attr_reader :briefcases, :root

      def initialize(options={})
        @root = Pathname(options.fetch(:root))
        @briefcases = {}.to_mash
        @briefcase_options = options.fetch(:briefcase_options, {})
        load_briefcases
      end

      def briefcase_options
        (@briefcase_options || {})
      end

      def load_briefcases
        config_path = briefcase_options.fetch(:config_path, "brief.rb")

        root.children.select(&:directory?).each do |dir|
          if dir.join(config_path).exist?
            slug = dir.basename.to_s.parameterize
            @briefcases[slug] ||= Brief::Briefcase.new(briefcase_options.merge(root: dir))
          end
        end
      end

    end
  end
end
