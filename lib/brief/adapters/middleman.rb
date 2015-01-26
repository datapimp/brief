module Brief::Adapters
  class MiddlemanExtension
    def self.activate_brief_extension
      ::Middleman::Extensions.register(:brief, Brief::Adapters::MiddlemanExtension)
    end

    def initialize(app, options_hash = {}, &block)
      super

      app.include(ClassMethods)

      options_hash.each do |key, value|
        app.set(key, value)
      end
    end
  end
end
