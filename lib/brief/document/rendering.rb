require 'github/markdown'

module GitHub
  class Markdown
    def self.render_pure_gfm(content)
      self.to_html(content, :gfm)
    end

    def self.render_gfm(content)
      render_pure_gfm(content).tap do |html|
        html.gsub!(/<h([1-6])>(.+?)<\/h\1>/,"<h\\1 data-level='\\1' data-heading='\\2'>\\2<\/h\\1>")
      end
    end
  end
end

module Brief
  class Document
    module Rendering
      extend ActiveSupport::Concern

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
        # remove annoying linebreaks from paragraphs
        parser.css("p br").remove() unless Brief.configuration.preserve_gfm_line_breaks

        parser.to_html
      end

      protected

      def to_raw_html
        renderer.render_gfm(content)
      end

      def renderer
        @renderer ||= GitHub::Markdown
      end

      attr_writer :renderer
    end
  end
end
