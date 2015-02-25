class Brief::Apps::Blueprint::Persona
  include Brief::Model

  meta do
    title
  end

  content do
    title "h1:first-of-type"
    temp "h1:first-of-type"
    paragraph "p:first-of-type"
  end
end
