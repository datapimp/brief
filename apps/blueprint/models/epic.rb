class Brief::Apps::Blueprint::Epic
  include Brief::Model

  meta do
    title
    subheading
    status String, :in => %w(draft published)
  end

  example <<-EOF
---
type: epic
status: draft
---

# Epic Title

Write a description for your epic.

# User Stories

## User Story Title

As a **PERSONA** I would like to **BEHAVIOR** so that I can **GOAL**
  EOF

  template <<-EOF
# <%= object.title %>
# User Stories
<% Array(object.user_stories).each do |user_story| %>
## <%= user_story.title %>
As a **User** I would like to **Do this** so that I can **succeed**
<% end %>
  EOF

  content do
    title "h1:first-of-type"
    paragraph "p:first-of-type"
    paragraphs "p"

    define_section "User Stories" do
      each("h2").has(:title     => "h2",
                     :paragraph => "p:first-of-type",
                     :components   => "p:first-of-type strong"
                    )

      each("h2").is_a :user_story
    end
  end

  helpers do
    def user_stories
      sections.user_stories.items.map do |item|
        item.components = Array(item.components)

        item.merge(goal: item.components[2],
                   persona: item.components[0],
                   behavior: item.components[1])
      end
    end
  end

  actions do
    def publish_to_github
    end

    def custom_action
    end
  end

end
