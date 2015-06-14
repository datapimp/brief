class Brief::Apps::Blueprint::Sitemap
  include Brief::Model

  defined_in Pathname(__FILE__)

  meta do
    title
    status
    revision
    project
    personas
  end

  content do
    define_section("Pages") do
      each("h2").has(:title=>"h2:first-of-type")
    end
  end
end
