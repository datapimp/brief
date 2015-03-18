class Brief::Apps::Blueprint::Diagram
  include Brief::Model

  meta do
    title
    subheading
    status String, :in => "draft published"
  end

  content do
    title "h1:first-of-type"

    subheading "h2:first-of-type"

    define_section "Annotations" do
      each("h2").has(:title => "h3",
                     :paragraphs => "p",
                     :settings => "code")
    end
  end
end

