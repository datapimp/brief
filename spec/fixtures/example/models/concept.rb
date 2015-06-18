class Brief::Concept
  include Brief::Model

  meta do
    title
    needle
    subheading
    status String, :in => %w(draft published)
  end

  content do
    title "h1:first-of-type"
  end

  new_doc_template do
    "The concept new doc template"
  end

  new_doc_name do
    "somecustomname.md"
  end
end
