class Brief::Epic
  include Brief::Model

  meta do
    title
    subheading
    status String, :in => %w(draft published)
  end

  content do
    title "h1:first-child"

    define_section "User Stories" do
      heading("h2").is_a :user_story

      heading("h2").has(:title     => "h2",
                     :paragraph => "p:first-child",
                     :persona   => "p:first-child strong:first-child",
                     :behavior  => "p:first-child strong:second-child",
                     :goal      => "p:first-child strong:third-child"
                    )
    end
  end

  actions do
    def custom_action
    end
  end
end
