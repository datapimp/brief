class Brief::Epic
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
    # have to do this so that the user stories section h1 doesnt get confused
    title "h1:first-of-type"

    # Example Markdown
    #
    # # User Stories
    #
    # ## A user wants to write epics
    #
    # As a **User** I would like to **write an epic** so that I can **write a bunch of user stories in one file**
    #
    # ## A user wants to turn an epic into trackable user stories
    #
    # As a **User** I would like to **publish an epic** so that i can **put the user stories in the queue**
    #

    # So given we have a heading called 'User Stories'
    # then we expect to have some h2 level headings underneath it
    define_section "User Stories" do
      # each one of those will be accessible on the document via:
      #
      #   document.sections.user_stories.items #=> [{title,paragraph,components}]
      each("h2").has(:title     => "h2",
                     :paragraph => "p:first-of-type",
                     :components   => "p:first-of-type strong"
                    )

      # NOT YET Implemented
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
    def custom_action

    end
  end
end
