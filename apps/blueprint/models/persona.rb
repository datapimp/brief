class Brief::Apps::Blueprint::Persona
  include Brief::Model

  defined_in Pathname(__FILE__)

  meta do
    title
    icon
    tags Array
  end

  content do
    title "h1:first-of-type"
    summary "p:first-of-type"

    define_section("Requirements") do
      each("li").has(:content => "li")
    end
  end
end
