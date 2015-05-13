class Brief::Apps::Blueprint::Release
  include Brief::Model

  defined_in Pathname(__FILE__)

  meta do
    title
    status
    tags Array
  end

  content do
    paragraph "p:first-of-type"
    paragraps "p"
    title "h1:first-of-type", :hide => true
    tagline "h2:first-of-type", :hide => true
    yaml_data "code.yaml:first-of-type", :serialize => :yaml, :hide => true

    define_section "User Stories" do
      each("h2").has(:title     => "h2",
                     :paragraph => "p:first-of-type",
                     :components   => "p:first-of-type strong"
                    )
    end
  end
end
