class Brief::Apps::Blueprint::Roadmap
  include Brief::Model

  defined_in Pathname(__FILE__)

  meta do
    title
    subheading
  end

  content do
    title "h1:first-of-type"
    subheading "h2:first-of-type"

    define_section "Milestones" do
      each("h2").has(:title => "h2", :due_date => "h3:first-of-type", :paragraph => "p:first-of-type")
    end
  end
end
