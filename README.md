# Brief 

An ActiveRecord style layer on top of a folder of markdown files.

Treat your markdown documents as active models, run actions on them,
convert them into HTML, extract fragments of HTML, combine it all in
whatever interesting way you can think of.  

The end result is a really neat way of being able to use the words that you write
to power all sorts of applications. 

**No more writing dead documents!**

### Documents as Models

Brief lets you treat an individual markdown file as if it were a model,
complete with validations, callbacks, and methods you can run. You can
define a `Post` model for all of the files in a 'posts' folder and
define actions like 'publish' on them. 

```ruby
define "Post" do
  meta do
    status
    tags Array
  end

  content do
    has_one :title, "h1"
    has_many :subheadings, "h2"
  end

  actions do
    def publish
      update_attributes(:status => "published")
    end
  end
end
```


### Model attributes derived from YAML frontmatter 

Models can get their attributes from headers on the document, aka YAML frontmatter.

```markdown
---
status: draft
tags: 
  - demo
  - sample
---

# Title

## Section One
## Section Two
```

which will let you use it like such:

```ruby
post = Brief::Document.new(/path/to/doc.html.md)

post.status #=> "draft"
post.title #=> "Title"
post.tags #=> ['demo','sample']
```

#### Model attributes derived from the document structure

Models can also get their attributes from the structure itself.

```ruby
post.title #=> "Title"
post.subheadings #=> ["Section One", "Section Two"]
```

### Querying Documents

Given a big folder of markdown files with attributes, we can query them:

```
posts = briefcase.posts.where(:status => "published")
posts.map(&:title) #=> ['Title']
```

This functionality is based on https://github.com/ralph/document_mapper,
and similar to middleman.

### Document Actions

By defining actions on documents like so:

```ruby

define "Post" do
  actions do
    def publish
      # DO Something
    end
  end
end
```

you can either call that method as you normally would: 

```ruby
post = Brief.case.posts.where(:status => "draft")
post.publish()
```

or you can run that action from the command line:

```bash
brief publish posts ./posts/*.html.md
```

this will find all of the post models matching the document, and then
call the publish method on them.
