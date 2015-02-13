module Brief::Server::Handlers
  class Modify
    def self.handle(path_args, briefcase, options={})
      action = options.fetch(:action)
      request = options.fetch(:request)

      writer = Writer.new(briefcase, path_args, request.params.symbolize_keys)

      headers = {"Content-Type"=>"application/json"}

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
        contents  = params[:contents]

        if path && path.exist?
          @errors[:path] = "Path already exists"
          return @errors
        end

        doc = Brief::Document.new(path).tap do |document|
          document.content = contents if contents.to_s.length > 0
          document.data = data if data && !data.empty?
          document.save!
        end

        doc.to_model
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
        document = Brief::Document.new(path)

        if document.nil? || !document.exist?
          @errors[:document] = "No document was found at #{ path_args }"
          @errors
        else
          document.contents = params[:contents] if params[:contents]
          document.data = (document.data || {}).merge(params[:data]) if params[:data].is_a?(Hash)
          document.save

          document.to_model
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
