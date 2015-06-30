  class BlueprintMiddlemanExtension < ::Middleman::Extension

    option :blueprint_root, nil, 'Which path to use for the blueprint?'

    def initialize(app, options_hash = {}, &block)
      super

      app.set(:blueprint_root, Pathname(options_hash.fetch(:blueprint_root) { ENV['BLUEPRINT_ROOT'] || "./blueprint" }))

      # import the blueprint assets into the sprockets path
      app.ready do
        logger.info "== Loading blueprint from #{ blueprint_root }"
        logger.info "== Appending #{ blueprint.assets_path } to Sprockets paths" if blueprint.assets_path.exist?

        patterns = [
          '.png',  '.gif', '.jpg', '.jpeg', '.svg', # Images
          '.eot',  '.otf', '.svc', '.woff', '.ttf', # Fonts
          '.js', '.slim', '.erb', '.md',                                    # Javascript
        ].map { |e| File.join(blueprint.assets_path, "**", "*#{e}" ) }

        sprockets.prepend_path(blueprint.assets_path)

        patterns.map! {|p| Dir[p] }
        patterns.flatten!

        patterns.each do |f|
          sprockets.import_asset(Pathname.new(f).relative_path_from(Pathname.new(blueprint.assets_path)))
        end
      end
    end

    helpers do
      def blueprint_model_groups
        blueprint.model_classes.map {|m| m.name.to_s.pluralize }
      end

      def blueprint
        @blueprint ||= get_briefcase.tap do |b|
          b.href_builder = ->(uri) {uri = uri.to_s; uri.gsub('brief://','').gsub(/\.\w+$/,'.html').gsub(b.docs_path.to_s,'') }
          b.asset_finder = ->(asset) { needle = asset.relative_path_from(b.assets_path).to_s; image_path(needle) }
        end
      end

      def get_briefcase
        Brief::Briefcase.new(root: blueprint_root, caching: false)
      end
    end
  end if defined?(::Middleman)

::Middleman::Extensions.register(:blueprint, BlueprintMiddlemanExtension) if defined?(::Middleman)
