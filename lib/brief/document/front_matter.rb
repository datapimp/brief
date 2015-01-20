module Brief
  class Document
    module FrontMatter
      extend ActiveSupport::Concern

      def frontmatter
        @frontmatter || load_frontmatter
      end

      def frontmatter_line_count
        (@raw_frontmatter && @raw_frontmatter.lines.count) || 0
      end

      protected

      def load_frontmatter
        if raw_content =~ /^(---\s*\n.*?\n?)^(---\s*$\n?)/m
          self.content = raw_content[($1.size + $2.size)..-1]
          @frontmatter_line_count = $1.lines.size
          @raw_frontmatter = $1
          @frontmatter = YAML.load($1).to_mash
        end
      end
    end
  end
end
