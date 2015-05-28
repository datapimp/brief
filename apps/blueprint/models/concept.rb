class Brief::Apps::Blueprint::Concept
  include Brief::Model

  defined_in Pathname(__FILE__)

  meta do
    title
  end

  content do
    title "h1:first-of-type"
    paragraph "p:first-of-type"
  end
end
