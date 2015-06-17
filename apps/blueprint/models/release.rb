class Brief::Apps::Blueprint::Release
  include Brief::Model

  defined_in Pathname(__FILE__)

  meta do
    title
    status
    personas
    project
    tags Array
    projects Array
  end

  content do
    paragraph "p:first-of-type"
    paragraphs "p"

    title "h1:first-of-type", :hide => true
    tagline "h2:first-of-type", :hide => true
    yaml_data "code.yaml:first-of-type", :serialize => :yaml, :hide => true

    define_section "Features" do
      each("h2").has(:title     => "h2",
                     :paragraph => "p:first-of-type",
                     :components   => "p:first-of-type strong"
                    )
    end
  end
end
