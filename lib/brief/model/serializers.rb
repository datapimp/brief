module Brief::Model::Serializers
  def as_json
    {
      data: data,
      path: path.to_s,
      type: type,
      actions: self.class.defined_actions,
      urls: {
        view_content_url: "/view/content/#{ path }",
        view_rendered_url: "/view/rendered/#{ path }",
        view_details_url: "/view/details/#{ path }",
        update_url: "/update/#{ path }",
        remove_url: "/remove/#{ path }",
        schema_url: "/schema/#{ type }",
        actions_url: "/actions/:action/#{ path }"
      }
    }
  end
end
