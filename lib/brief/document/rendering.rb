module Brief
  class Document
    module Rendering
      extend ActiveSupport::Concern

      def to_html
        structure.parser.to_html
      end

      def structure
        @structure_analyzer ||= Brief::Document::StructureAnalyzer.new(parser, self.raw_content.lines.to_a)
      end

      def to_raw_html
        renderer.render(content)
      end

      def renderer
        @renderer ||= self.class.renderer
      end

      def renderer=(value)
        @renderer = value
      end

      def css(*args, &block)
        processed.send(:css, *args, &block)
      end

      def at(*args, &block)
        processed.send(:at, *args, &block)
      end

      def processed
        structure.parser
      end

      def parser
        @parser ||= Nokogiri::HTML.fragment(to_raw_html)
      end

      class HeadingWrapper < ::Redcarpet::Render::HTML
        def header(text, level)
          "<h#{level} data-level='#{level}' data-heading='#{ text }'>#{text}</h#{level}>"
        end
      end

      module ClassMethods
        def renderer_class
          HeadingWrapper
        end

        def renderer
          @renderer ||= begin
                          r = renderer_class.new(:tables => true,
                                            :autolink => true,
                                            :gh_blockcode => true,
                                            :fenced_code_blocks => true,
                                            :footnotes => true)

                          ::Redcarpet::Markdown.new(r)
                        end
        end
      end
    end
  end
end
