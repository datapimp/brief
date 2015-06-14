class Brief::Apps::Blueprint::Persona
  include Brief::Model

  defined_in Pathname(__FILE__)

  meta do
    title
    projects
  end

  content do
    title "h1:first-of-type"
    paragraph "p:first-of-type"
  end
end
