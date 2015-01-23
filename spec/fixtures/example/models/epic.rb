class Brief::Epic
  include Brief::Model

  meta do
    title
    subheading
    status String, :in => %w(draft published)
  end

  content do
    # have to do this so that the user stories section h1 doesnt get confused
    title "h1:first-of-type"

    define_section "User Stories" do
      # NOT YET Implemented
      each("h2").is_a :user_story

      each("h2").has(:title     => "h2",
                     :paragraph => "p:first-of-type",
                     :components   => "p:first-of-type strong"
                    )
    end
  end

  actions do
    def custom_action
    end
  end
end
