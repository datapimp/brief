class Brief::Page
  include Brief::Model

  meta do
    title
  end

  content do
    title "h1:first-of-type"
    paragraph "p:first-of-type"
    yaml_data "pre[lang='yaml']:first-of-type code", :serialize => :yaml
  end
end
