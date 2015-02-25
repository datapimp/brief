class Brief::Page
  include Brief::Model

  meta do
    title
  end

  content do
    title "h1:first-of-type"
    paragraph "p:first-of-type"
    yaml_block "code.yaml:first-of-type", :serialize => :yaml
  end
end
