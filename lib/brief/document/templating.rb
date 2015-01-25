module Brief::Document::Templating
  extend ActiveSupport::Concern

  def generate_content
    model_class.generate_template_content_from(@frontmatter)
  end

  module ClassMethods
    def create_from_data(data={})
      data = data.to_mash if data.is_a?(Hash)
      new(data)
    end
  end
end
