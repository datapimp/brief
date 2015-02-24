class Page
  include Brief::Model

  meta do
    title
    category
    tags Array
  end

  content do
    title "h1:first-of-type"
    paragraph "p:first-of-type"
  end
end
