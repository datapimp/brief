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

  prompt do
    "asdf"
  end
end
