class Brief::Apps::Blueprint::Diagram
  include Brief::Model

  defined_in Pathname(__FILE__)

  meta do
    title
    subheading
    projects
    personas
    status String, :in => "draft published"
  end

  content do
    title "h1:first-of-type"

    subheading "h2:first-of-type"

    define_section "Annotations" do
      each("h2").has(:title => "h2",
                     :paragraphs => "p",
                     :settings => "code")
    end
  end
end

