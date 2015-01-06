# Brief

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
# brief publish posts /path/to/*.html.md.
action "publish posts" do |briefcase, models, options|

  say "== Publishing #{ models.length } posts"

  Array(models).each do |post|
    post.publish()
  end
end
```
