module Brief::Model::Serializers
  def as_json(options={})
    options.symbolize_keys!

    if options[:docs_path]
      if path.absolute?
        doc_path = path.relative_path_from(options[:docs_path])
      else
        doc_path = path
      end
    else
      doc_path = path.to_s
    end

    # TEMP
    title = data.try(:[], :title) || extracted_content.try(:title) || (send(:title) rescue nil) || path.basename.to_s.gsub(/\.html.md/,'')
    title = title.to_s.gsub(/\.md/,'')

    {
      data: data,
      extracted: extracted_content_data,
      path: doc_path.to_s,
      type: type,
      title: title,
      actions: self.class.defined_actions,
      urls: {
        view_content_url: "/view/content/#{ doc_path }",
        view_rendered_url: "/view/rendered/#{ doc_path }",
        view_details_url: "/view/details/#{ doc_path }",
        update_url: "/update/#{ doc_path }",
        remove_url: "/remove/#{ doc_path }",
        schema_url: "/schema/#{ type }",
        actions_url: "/actions/:action/#{ doc_path }"
      }
    }.tap do |h|
      h[:content] = document.combined_data_and_content if options[:content]
      h[:rendered] = document.to_html if options[:rendered]
    end
  end
end
