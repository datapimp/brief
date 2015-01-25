# Brief 

Brief is a tool for building applications on top of collections of
documents written in markdown.  

Brief lets you define models very similar to how you would in
ActiveRecord and Rails, but instead of rows in a database you are 
going to be working with files in a folder.

### Getting Started
```
gem install brief
brief --help
```

### Hypothetical Example

```
brief init my-cookbook
cd my-cookbook
brief generate model Recipe # View the DOCUMENTATION for what you can do with a model
brief write recipe # => opens up your $EDITOR with an example recipe
```

Brief treats each markdown file as an active record style model object. It treats a folder of markdown files like a database.

### How does it work?

Brief takes a markdown file which looks like:

```markdown
---
type: post
status: active
---

# An introduction to brief 
## Stop writing dead documents 

Brief is a tool which lets you define different patterns of markdown
headings (h1,h2,h3 etc). This lets you work with collections of your
writings, and treat each document as a database. 
```

And turns it into data, not only using the metadata up top, but also the information
contained in the structure of the document itself.  The headings, subheadings, pretty much
anything you could query from the HTML using CSS can be turned into key value pairs that you can work
with and build applications on top of.

With your enhanced writing, you can do things like:

```ruby
# Find all the posts which are active:
posts = briefcase.posts.where(status:"published")

# Get their titles, and subheadings:
posts.map(&:title) #=>['An introduction to brief']
posts.map(&:subheading) #=>['Stop writing dead documents']

# Publish the post
posts.first.publish()

# Email the drafts to your editor
posts.where(status:"draft").each &:mail_to_editors
```

From the Command line we can:

```bash
brief publish posts 
brief write post #=> Opens your editor
```

This type of interactivity is made possible by the `Brief::Model`

### Documents as models

```ruby
define "Post" do
  meta do
    status
  end

  content do
    title "h1:first-of-type"
    subheading "h2:first-of-type"
    sample "p:first-of-type"
  end

  actions do
    def publish
      update_attributes(status: "published")
    end
  end
end
```

### CLI Tool

Brief gives you a CLI called `brief`

This lets you run some general commands, but also gives you an
intelligent interface to work with your models.  In the above example,
we defined some actions.

This will be available in the CLI:

```
brief publish posts ./docs/posts/*.md
```

This will find all of the matching documents, turn them into `Post`
models, and then run the publish method on them.  You can make your
models as advanced as you want:

```
define "Post" do
  actions do
    def submit 
      update_attributes(status:"submitted to editors")
      mailer.send(:to => "jon@chicago.com", :subject => "Please review: #{ self.title }")
    end
  end
end
```

### YAML Frontmatter

Each markdown document can contain YAML frontmatter.  This data will be
available and associated with each document or model, and will also let
you query, filter, and sort your documents.

### CSS Structure Definition

Since markdown renders into HTML, and HTML Documents can be queried
using CSS selectors, we use CSS selectors in our model definition DSL so
that we can isolate certain parts of the document, and use the content
it contains as metadata.

A real world example:

```ruby
  content do
    title "h1:first-of-type"
    define_section "User Stories" do
      each("h2").has(:title     => "h2",
                     :paragraph => "p:first-of-type",
                     :components   => "p:first-of-type strong"
                    )

      each("h2").is_a :user_story
    end
  end
```

This lets me turn a markdown file like:

```markdown
---
title: Epic Example
status: published
---
# Epic Example
# User Stories

## A user wants to do something
As a **User** I would like to **Do this** so that I can **succeed**

## A user wants to do something else
As a **User** I would like to **Do this** so that I can **succeed**
```

into:

```ruby
{
  title: "Epic Example",
  status: "published",
  type: "epic",
  user_stories:[{
    title: "A user wants to do something",
    paragraph: "As a user I would like to do something so that I can succeed",
    goal: "I can succeed",
    persona: "user",
    behavior: "do something"
  },{
    title: "A user wants to do something else",
    paragraph: "As a user I would like to do something else so that I can succeed"
  }]
}
```

And we can even go in the other direction.
