class Brief::Apps::Blueprint::Page
  include Brief::Model

  defined_in Pathname(__FILE__)

  meta do
    title
    category
    tags Array
  end

  content do
    paragraph "p:first-of-type"
    title "h1:first-of-type", :hide => true
    tagline "h2:first-of-type", :hide => true
    yaml "pre[lang='yaml'] code:first-of-type", :serialize => :yaml, :hide => true
  end
end
