class Brief::Apps::Blueprint::Sitemap
  include Brief::Model

  meta do
    title
    status
    revision
  end

  content do
    define_section("Pages") do
      each("h2").has(:title=>"h2:first-of-type")
    end
  end
end
