class Brief::Apps::Blueprint::Wireframe
  include Brief::Model

  defined_in Pathname(__FILE__)

  meta do
    title
    parent_title
    category
    tags
    annotations Hash
  end
end
