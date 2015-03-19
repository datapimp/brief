class Brief::Apps::Blueprint::Outline
  include Brief::Model

  meta do
    type
  end

  content do
    h1 "h1"
    h2 "h2"
    h3 "h3"
    h4 "h4"
    h5 "h5"
    h6 "h6"
    headings "h1,h2,h3,h4,h5,h6"
    settings "code.yaml:first-of-type", :serialize => :yaml, :hide => true
  end
end
