module Brief::Adapters
  class MiddlemanExtension < ::Middleman::Extension
    def self.activate_brief_extension
      ::Middleman::Extensions.register(:brief, Brief::Adapters::MiddlemanExtension)
    end

    def initialize(app, options_hash = {}, &block)
      super

    end

    helpers do
      def brief_config_path
        Pathname(root).join("brief.rb")
      end

      def briefs
        briefcase
      end

      def briefcase
        if !brief_config_path.exist?
          brief_config_path.open("w+") {|fh| fh.write("# See github.com/datapimp/brief for documentation")}
        end

        if development?
           Brief::Briefcase.new(root: root,
                                config_path: brief_config_path,
                                caching: false)
        else
          @briefs ||= begin
                       Brief::Briefcase.new(root: root,
                                            config_path: brief_config_path,
                                            caching: true)
                     end
        end
      end
    end

  end
end
