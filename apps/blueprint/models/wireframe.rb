class Brief::Apps::Blueprint::Wireframe
  include Brief::Model

  defined_in Pathname(__FILE__)

  meta do
    title
    parent_title
    image
    sitemap
    project
    features
    category
    tags Array
    annotations Hash
  end

  content do
    define_section("System Interactions") do
      each("h2").has(:title => "h2", :paragraph => "p:first-of-type", :link => "a")
    end
  end
end
