module Brief::Server::Handlers
  class Modify
    def self.handle(path_args, briefcase, options={})
      action = options.fetch(:action)
      request = options.fetch(:request)

      writer = Writer.new(briefcase, path_args, request.params.symbolize_keys)

      headers = {"Content-Type"=>"application/json", "X-BRIEF-MODIFY-ACTION"=>action}

      response = writer.run(action)

      if writer.has_errors?
        [500, headers, {errors: writer.errors, path: path_args}]
      else
        [200, headers, response]
      end
    end

    class Writer
      attr_accessor :briefcase, :params, :path

      def initialize(briefcase, path_args, params)
        @params = params
        @briefcase = briefcase
        @errors = {}
        @path = briefcase.normalize_path(path_args)

        raise "Invalid path for document write" unless @path
      end

      def run(action)
        if !respond_to?(action)
          @errors[:action] = "invalid"
          return @errors
        end

        send(action)
      end

      def ok?
        @errors.empty?
      end

      def has_errors?
        not ok?
      end

      def create
        data      = params[:data]
        contents  = params[:content] || params[:contents]
        raw       = params[:raw]

        if path && path.exist?
          @errors[:path] = "Path already exists"
          return @errors
        end

        doc = Brief::Document.new(path).tap do |document|
          document.in_briefcase(briefcase)

          if raw
            document.raw = raw
          elsif contents || data
            document.content = contents if contents.to_s.length > 0
            document.data = data if data && !data.empty?
          end

          document.save!
        end

        doc.to_model.as_json(content: true, rendered: true)
      end

      def remove
        doc = Brief::Document.new(path)
        doc.path.unlink rescue nil

        {
          success: ok?,
          path: path
        }
      end

      def update
        data      = params[:data]
        contents  = params[:content] || params[:contents]
        raw       = params[:raw]

        document  = briefcase.document_at(path)

        if document.nil? || !document.exist?
          @errors[:document] = "No document was found at #{ path_args }"
          @errors
        else
          if raw
            document.raw = raw
          elsif contents || data
            document.content = contents if contents.to_s.length > 0
            document.data = (document.data || {}).merge(params[:data]) if params[:data].is_a?(Hash)
          end

          document.save

          document.to_model.as_json(content: true, rendered: true)
        end
      end

      def delete
        remove
      end

      def errors
        @errors || {}
      end
    end
  end
end
