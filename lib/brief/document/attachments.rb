module Brief::Document::Attachments
  def has_attachments?
    attachments.length > 0
  end

  def attachments
    Array(data.attachments)
  end

  def render_attachments
    attachments.reduce({}.to_mash) do |memo, attachment|

    end
  end
end
