module Brief
  class Document
    module FrontMatter
      extend ActiveSupport::Concern

      def frontmatter
        @frontmatter || load_frontmatter
      end

      protected

      def load_frontmatter
        if content =~ /^(---\s*\n.*?\n?)^(---\s*$\n?)/m
          self.content = content[($1.size + $2.size)..-1]
          @frontmatter = YAML.load($1).to_mash
        end
      end
    end
  end
end
