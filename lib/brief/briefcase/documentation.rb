module Brief
  class Briefcase
    module Documentation

      class ModelDoc
        def initialize(path)
          @content = Pathname(path).read rescue ""
        end

        def content
          @content
        end

        def rendered
          ::GitHub::Markdown.render_gfm(content)
        end
      end

      def render_documentation(include_all=false)
        list = include_all ? Brief::Model.classes : model_classes

        list.reduce({}.to_mash) do |memo, klass|
          docs = klass.to_documentation rescue {}
          memo[klass.type_alias] = docs unless docs.empty?
          memo
        end
      end

      def schema_map(include_all=false)
        list = include_all ? Brief::Model.classes : model_classes
        list.map(&:to_schema)
          .reduce({}.to_mash) {|m, k| m[k[:type_alias]] = k; m }
      end
    end
  end
end
