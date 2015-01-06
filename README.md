# Brief 

An ActiveRecord style layer on top of a folder of markdown files.

### No more dead documents 

Brief is a tool that lets you build simple applications on top of
collections of markdown files.  The metaphor we use is a briefcase,
which contains folders with different document types.

Every document type, or model, can define a simple schema of attributes, 
which can be specified in a YAML frontmatter preamble at the very top of
each document.  

In addition to frontmatter metadata, you can declare other model
attributes as CSS selectors.  For example, the very first h1 heading
could be the title for your document, and the corresponding model for
that document would have a `title` method which returned its value.

This is a great way to build applications whose primary interface is the
text editor, allowing writing and thought to flow as freely as possible
and to later be used to power some automation tasks.

**Think of it as an ActiveRecord like layer on top of a folder of
Markdown files**.  Brief turns static text into a 'living' data object.

## Getting started 

```bash
gem install brief
mkdir blog
cd blog 
brief init
```

This will create a new folder for your briefcase, along with the
following config file and structure.

```
- docs/
  - an-introduction-to-brief.html.md
- models/
- brief.rb
```

The config file will look like:

```ruby

# configuration options for this briefcase
config do
  set(:models_path => Pathname(__FILE__).parent.join("models"))
end

# define a Post model
define("Post") do

  # the post model will have YAML frontmatter 
  # with values for 'status' and 'date'
  meta do
    status
    date DateTime, :default => lambda {|post, attr| post.document.created_at }
  end
  
  # the post model will have a 'title' method which returns the text
  # from the first h1 heading
  content do
    title "h1"
    has_many :subheadings, "h2"
  end

  helpers do
    def publish(options={})

    end
  end
  
  # Whenever we call post.save() and the status attribute changes
  # from draft to published, do something with the model
  on_status_change(:from => "draft", :to => "published") do |model|
    # Do Something
    # mail_service.send_html_email_campaign(model.to_html)
  end
end

# this creates a custom command in the brief CLI tool
#
# so when you run:
# 
#   brief publish posts /path/to/*.html.md.
#
# the brief CLI will find models for the post files you reference,
# and call whatever methods you want.

action "publish posts" do |briefcase, models, options|

  say "== Publishing #{ models.length } posts"

  Array(models).each do |post|
    post.publish()
  end
end
```

### Real World Application

My company Architects.io, Inc. uses brief to power our Blueprint
software.  A Blueprint is a collection of related documents that are
used in the software architecture and design process, as well as in the
day to day writing that takes place while building the software itself.

This includes things like:

- daily standups
- bug reports
- code reviews
- feature epics
- user stories
- integration tests
- release notes
- wireframe annotations

All of these things are simple markdown files.  They live in the
projects we are working on, and by treating our writing as a structured
exercise we are able to do a lot more things with it than just read it.

For example we can do:

```
brief publish user stories /path/to/user-stories/*.html.md
```

which is implemented by:

```ruby
# brief.rb

define "User Story" do
  meta do
    status
  end

  content do
    title "h1"
    paragraph "p:first-child"
    persona "p:first-child strong:1st-child"
    behavior "p:first-child strong:2nd-child"
    goal "p:first-child strong:3rd-child"
  end

  helpers do
    def create_github_issue
      issue = github.create_issue(title: title, body: document.content)
      set(issue_number: issue.number)
    end
  end
end

action "publish user stories" do |briefcase, models, options|
  user_stories = models

  user_stories.each do |user_story|
    if user_story.create_github_issue()
      user_story.status = "published"
      user_story.save
    end
  end
end
```

As you can see, Brief can be a way to make your Markdown writing efforts
much more productive. 
