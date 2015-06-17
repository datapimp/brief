class Brief::Apps::Blueprint::Milestone
  include Brief::Model

  defined_in Pathname(__FILE__)

  meta do
    title
    number
    projects
    personas
    due_date
    tags Array
  end

  content do
    title "h1:first-of-type", :hide => true
    paragraph "p:first-of-type"
    paragraphs "p"
    yaml_data "code.yaml:first-of-type", :serialize => :yaml, :hide => true
  end
end
