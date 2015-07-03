module Brief::RemoteSyncing
  extend ActiveSupport::Concern

  def publish_service
    case
    when briefcase && briefcase.uses_app?
      [briefcase.app, self.class.name.to_s.split('::').last, 'publisher'].join("_").camelize.constantize
    end
  end

  def sync_service
    case
    when briefcase && briefcase.uses_app?
      [briefcase.app, self.class.name.to_s.split('::').last, 'publisher'].join("_").camelize.constantize
    end
  end
end
