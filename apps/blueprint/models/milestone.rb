class Brief::Apps::Blueprint::Milestones
  include Brief::Model

  meta do
    title
    number
    due_date
  end

  content do
    title "h1:first-of-type", :hide => true
    paragraph "p:first-of-type"
    paragraphs "p"
    yaml_data "code.yaml:first-of-type", :serialize => :yaml, :hide => true
  end
end