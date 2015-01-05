class Brief::Epic
  include Brief::Model

  meta do
    title String
    status String, :in => %w(draft published)
  end

  content do
    title "h1:first-child"

    define_section "User Stories" do
      has_many :user_stories, "h2" => "title", "p:first-child" => "paragraph"
    end
  end
end
