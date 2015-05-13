module Brief
  class Document
    module Attachments
      def has_attachments?
        attachments.length > 0
      end

      def attachments
        Array(data.attachments)
      end

      def attachment_paths
        attachments.reduce({}.to_mash) do |memo, name|
          if asset = briefcase.find_asset(name)
            memo[name] = asset.realpath.to_s
            memo
          end
        end
      end

      def render_attachments
        attachments.reduce({}.to_mash) do |memo, name|
          if asset = briefcase.find_asset(name)
            memo[name] = IO.read(asset) if asset.to_s.match(/\.svg/i)
            memo
          end
        end
      end
    end
  end
end

