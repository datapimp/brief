module Brief
  class Document
    module Rendering
      extend ActiveSupport::Concern

      # Uses a custom Redcarpet::Render::HTML subclass
      # which simply inserts data attributes on each heading element
      # so that they can be queried with CSS more deliberately.
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
                          r = renderer_class.new(tables: true,
                                                 autolink: true,
                                                 gh_blockcode: true,
                                                 fenced_code_blocks: true,
                                                 footnotes: true)

                          ::Redcarpet::Markdown.new(r, :tables => true,
                                                       :autolink => true,
                                                       :gh_blockcode => true,
                                                       :fenced_code_blocks => true,
                                                       :footnotes => true)
                        end
        end
      end

      def script_preamble
        <<-EOF
        <script type="text/javascript">
        if(typeof(global)==="undefined"){
          global = window
        }
        global.Brief = global.Brief || {}
        Brief.documents = Brief.documents || {}
        </script>
        EOF
      end

      def script_contents(options={})
        <<-EOF
        <script type="text/javascript">
        Brief.documents['#{ self.relative_path }'] = #{ to_model.as_json(options).to_json };
        </script>
        EOF
      end

      # Documents can be rendered into HTML.
      #
      # They will first be put through a Nokogiri processor pipeline
      # which allows us to wrap things in section containers, apply data
      # attributes, and other things to the HTML so that the output HTML retains its
      # relationship to the underlying data and document structure.
      def to_html(options = {})
        html = if options[:wrap] == false
          unwrapped_html
        else
          wrapper = options.fetch(:wrapper, 'div')
          "#{script_preamble if options[:script] && !options[:skip_preamble]}<#{ wrapper } data-brief-model='#{ model_class.type_alias }' data-brief-path='#{ relative_path }'>#{ unwrapped_html }</#{wrapper}>#{ script_contents(options) if options[:script]}"
        end

        html.respond_to?(:html_safe) ? html.html_safe : html.to_s
      end

      def unwrapped_html
        parser.to_html
      end

      protected

      def to_raw_html
        renderer.render(content)
      end

      def renderer
        @renderer ||= self.class.renderer
      end

      attr_writer :renderer
    end
  end
end
