# A Brief Introduction to Brief 

Brief provides an object / relational data layer on top of collections of markdown documents.  

It lets you use normal writing that occurs in files and folders with a person's favorite text editor 
as your application's main user interface.

A Briefcase is a folder which contains Markdown documents.  These
Markdown documents may contain YAML Frontmatter and/or Github Flavored
Markdown.  

Through either the `type` value that is specified as YAML in the header, 
or through the name of the folder it belongs to, a document can be
assigned a specific `Brief::Model` class which can give the document  
and writing the same kind of special powers we give to a row in a SQL
table.

### What is a Brief Model

The Model class acts as a specification for that type of document.  

The specification defines the metadata it expects to see, and the
general structure the document should follow.  It then lets the
programmer treat each individual document as an object, and do whatever
you want with it.

A document turned into a Brief object model will determine its state and
attributes in one of two ways:

1) YAML Frontmatter that gets embedded in the header of the document
2) Content extracted from the rendered markdown using a system of simple
   CSS selectors

### Why is this valuable?

I think this is great because a collection of markdown documents that
exists on Github is more than sufficient as a database of record for a
lot of different projects, and you get a lot of great features this way
for free such as audit trails, branching, discussions, task management,
etc.

Blogs are the most obvious example, but using Brief to write your blog
would be overkill.  Brief is made to power much more ambitious kinds of
applications, and making it easier to use text editors and written
language as one of the primary interfaces.

### An Example Brief Model

```ruby
class Post
  include Brief::Model
  
  meta do
    title
    subtitle
    status :default => "draft"
  end

  content do
    title "h1:first-of-type"
    subtitle "h2:first-of-type"
    excerpt "h3#excerpt p", hide: true
  end

  actions do
    def publish
      set(state:"published", published_at: Time.now)
      save
    end
  end
end
```

In this specification for the `Post` model, we declared some acceptable
values in the YAML frontmatter, such as the title and subtitle of the
post. 

We also say that the same values can be extracted from the document's h1
and h2 tags.

An example document might look like:

```markdown
---
type: post
title: Introduction to Brief
---

### Excerpt

We're going to go over some basics about the Brief gem. This content
won't be rendered in the final output, but will be extracted into an
excerpt attribute for the model. 

# Brief 
## An introduction to brief

This content will get rendered.
```

The Post model will turn this document into an object, and let us do 
different things with it in our code.

A post model can be used as application data in a Ruby app.

```ruby
post = Post.where(:title.matches => "Intro")
post.title # "Introduction to Brief"
post.status # "draft"
```

Or interacted with from the command line:

```bash
brief publish post docs/posts/introduction-to-brief.md
```

### The rest is up to you.

There is more to the gem which we will cover later, but this is
a very powerful way to build applications which are powered primarily by
structured writing.
