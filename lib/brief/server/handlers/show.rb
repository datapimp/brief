module Brief::Server::Handlers
  class Show
    def self.handle(path_args, briefcase, options={})
      action    = options.fetch(:action)
      request   = options.fetch(:request)
      parts     = path_args.split("/")
      view      = parts.shift.to_s.downcase
      path      = parts.join("/")

      document = begin
                   briefcase.document_at(path)
                 rescue Brief::Repository::InvalidPath
                   :forbidden
                 end

      code          = 200
      content_type  = "application/json"

      case
      when document.nil?
        code = 404
        body = {error: "Not found"}
      when document == :forbidden
        code = 403
        body = {error: "Access denied." }
      when !%w(content rendered details).include?(view)
        code = 400
        body = {error: "Invalid view: must be content, rendered, details" }
      when document && view == "content"
        body = document.combined_data_and_content
        content_type = "text/plain"
      when document && view == "rendered"
        body = document.to_html
        content_type = "text/html"
      when document && view == "details"
        body = document.to_model.as_json(request.params)
      end

      [code, {"Content-Type"=>content_type}, body]
    end
  end
end
