class Brief::Apps::Blueprint::Mockup
  include Brief::Model

  defined_in Pathname(__FILE__)

  meta do
    title
    parent_title
    sitemap
    project
    category
    tags
    annotations Hash
  end
end
