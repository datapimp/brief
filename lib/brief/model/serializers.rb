module Brief::Model::Serializers
  def as_json(options={})
    options.symbolize_keys!
    briefcase_docs_path = options.fetch(:docs_path) { briefcase.docs_path }
    briefcase_docs_path = briefcase_docs_path.to_pathname if briefcase_docs_path.is_a?(String)

    begin
      doc_path  = path.relative_path_from(briefcase_docs_path).to_s
    rescue
      doc_path = path.realpath.relative_path_from(briefcase_docs_path).to_s
    end

    # TEMP
    title = data.try(:[], :title) || extracted_content_data.try(:title) || (send(:title) rescue nil) || path.basename.to_s.gsub(/\.html.md/,'')
    title = title.to_s.gsub(/\.md/,'')

    {
      data: data,
      extracted: extracted_content_data,
      path: path.to_s,
      type: type,
      group: type.to_s.pluralize,
      title: document_title,
      actions: self.class.defined_actions,
      updated_at: File.mtime(path).to_i,
      id: Digest::MD5.hexdigest(path.to_s),
      hash: file_hash,
      sections: {},
      section_headings: [],
    }.tap do |h|
      h[:content] = document.combined_data_and_content if options[:content] || options[:include_content]
      h[:rendered] = document.to_html if options[:rendered] || options[:include_rendered]

      if options[:attachments] || options[:include_attachments]
        h[:attachments] = document.render_attachments
      end

      h[:urls] = {
        view_content_url: "/view/content/#{ doc_path }",
        view_rendered_url: "/view/rendered/#{ doc_path }",
        view_details_url: "/view/details/#{ doc_path }",
        update_url: "/update/#{ doc_path }",
        remove_url: "/remove/#{ doc_path }",
        schema_url: "/schema/#{ type }",
        actions_url: "/actions/:action/#{ doc_path }"
      } if options[:urls] || options[:include_urls]
    end.tap do |h|
      if document.has_sections?
        h[:section_headings] = document.section_headings
        h[:sections] = document.sections_data
      end
    end
  end
end
