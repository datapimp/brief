module Brief
  module Data
    class Queryable
      def initialize(array)
        @array = Array(array)
      end

      def where(*args, &block)
        Brief::DocumentMapper::Query.new(@array).send(:where, *args)
      end

      def method_missing(meth, *args, &block)
        @array.send(meth,*args,&block)
      end

    end

    class Wrapper
      attr_accessor :sources, :root

      def initialize(options={})
        @root = options.fetch(:root) { Pathname(Brief.pwd).join('data') }
        @sources = {}.to_mash

        load_files.each do |source, data|
          @sources[source] = Queryable.new(data)
        end
      end

      def method_missing(meth, *args, &block)
        return sources.send(meth, *args, &block) if sources.key?(meth)
        super
      end

      def load_files
        files = Dir[root.join("**/*.yml")] + Dir[root.join("**/*.json")] + Dir[root.join("**/*.yaml")]

        files.map! do |file|
          path = Pathname(file)

          if path.extname == ".json"
            key = "#{path.basename.to_s.gsub(/\.json$/i, '')}"
            data = JSON.parse(path.read)
          elsif path.extname == '.yml' || path.extname == ".yaml"
            key = "#{path.basename.to_s.gsub(/\.ya?ml$/i, '')}"
            data = YAML.load(path.read)
          else
            nil
          end

          {key => data} if key && data
        end

        files.compact.reduce({}) {|memo, hash| memo.merge(hash) }
      end
    end
  end
end
