module Brief
  module Model::Persistence
    extend ActiveSupport::Concern

    def set_data_attribute(attribute, value)
      document.data.send("#{attribute}=", value)
      document.save
      value
    end
  end
end
