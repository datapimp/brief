class Brief::Apps::Blueprint::Page
  include Brief::Model

  meta do
    title
    category
    tags Array
  end

  content do
    title "h1:first-of-type"
    tagline "h2:first-of-type"
    paragraph "p:first-of-type"
    yaml_data "code.yaml:first-of-type", :serialize => :yaml
  end
end
