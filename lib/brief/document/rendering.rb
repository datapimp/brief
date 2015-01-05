module Brief
  class Document
    module Rendering
      extend ActiveSupport::Concern

      def to_html
        self.class.renderer.render(content)
      end

      def css(*args, &block)
        parser.send(:css, *args, &block)
      end

      def at(*args, &block)
        parser.send(:at, *args, &block)
      end

      def parser
        @parser ||= Nokogiri::HTML.fragment(to_html)
      end

      module ClassMethods
        def renderer
          @renderer ||= begin
                          r = ::Redcarpet::Render::HTML.new(:tables => true,
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
