module Brief
  class Document
    module FrontMatter
      extend ActiveSupport::Concern

      def frontmatter= attributes
        @frontmatter = attributes
      end

      def data= attributes
        self.frontmatter= attributes
      end

      def frontmatter
        (@frontmatter || load_frontmatter).tap do |d|
          d[:type] ||= parent_folder_name && parent_folder_name.to_s.singularize if parent_folder_name && parent_folder_name.length > 0
        end
      end

      def frontmatter_line_count
        (@raw_frontmatter && @raw_frontmatter.lines.count) || 0
      end

      protected

      def load_frontmatter
        if raw_content =~ /^(---\s*\n.*?\n?)^(---\s*$\n?)/m
          self.content = raw_content[(Regexp.last_match[1].size + Regexp.last_match[2].size)..-1]
          @frontmatter_line_count = Regexp.last_match[1].lines.size
          @raw_frontmatter = Regexp.last_match[1]
          @frontmatter = YAML.load(Regexp.last_match[1]).to_mash
        else
          @frontmatter = {}.to_mash
        end
      end
    end
  end
end
