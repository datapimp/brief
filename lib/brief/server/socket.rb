module Brief
  class Server
    class Socket
      attr_reader :briefcases, :root, :websocket

      def initialize(options={})
        @root = Pathname(options.fetch(:root))
        @websocket = options.fetch(:websocket)
        @briefcases = {}.to_mash
        @briefcase_options = options.fetch(:briefcase_options, {})
        load_briefcases
        setup_interface
      end

      def process(message={})
        message.symbolize_keys!

        action      = message.fetch(:action)
        message_id  = message.fetch(:message_id)

        case

        when action == "brief:info"
          respond_to(message_id) do
            Brief.environment_info
          end

        when action == "list:briefcases"
          presenter = message.fetch(:presenter, 'default')
          options = message.fetch(:options, {})

          respond_to(message_id) do
            briefcases.values.map do |bc|
              bc.present(presenter, options)
            end
          end

        when action == "view:briefcase"
          presenter = message.fetch(:presenter, 'default')
          options = message.fetch(:options, {})
          briefcase = briefcases.fetch(message[:briefcase])

          respond_to(message_id) do
            briefcase.present(presenter, options)
          end

        when action == "view:document"
          options = message.fetch(:options, {})
          path = message.fetch(:path)
          briefcase = briefcases.fetch(message[:briefcase])

          respond_to(message_id) do
            document = briefcase.document_at(path)
            document.to_model.as_json(options)
          end

        when action == "query"
          params = message.fetch(:params, {})
          model_options = message.fetch(:model_options, {})
          briefcase = briefcases.fetch(message[:briefcase])

          respond_to(message_id) do
            briefcase.where(params).all.map do |model|
              model.as_json(model_options)
            end
          end

        else
          respond_to(message_id) do
            {error:"Invalid Action: #{ action }"}
          end
        end
      rescue
        nil
      end

      def respond_to(message_id, &block)
        body = block.call()

        payload = {
          action: "response",
          message_id: message_id,
          body: body
        }

        websocket.send(payload.to_json)
      end

      private

      def setup_interface
        socket = self

        websocket.onmessage do |raw|
          message = (JSON.parse(raw) rescue nil)

          puts "== Received Message: #{message}"
          socket.process(message)
        end
      end

      def briefcase_options
        (@briefcase_options || {})
      end

      def load_briefcases
        config_path = briefcase_options.fetch(:config_path, "brief.rb")

        root.children.select(&:directory?).each do |dir|
          if dir.join(config_path).exist?
            slug = dir.basename.to_s.parameterize
            @briefcases[slug] ||= Brief::Briefcase.new(briefcase_options.merge(root: dir))
          end
        end
      end

    end
  end
end
