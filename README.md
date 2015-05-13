# Brief 
[![Build
Status](https://travis-ci.org/datapimp/brief.svg?branch=master)](https://travis-ci.org/datapimp/brief)

### Putting your writing to work

Brief lets writers build applications on top of collections of markdown
files.  Brief lets you define different classes or types of documents, called
`Model`s.  

These models turn the documents into objects, which can be
used to do things such as make API calls, or publish a blog post and
send an email campaign at the same time. 

### Turn documents into data 

The most basic way of combining writing with data, is through the use of
YAML Frontmatter as metadata for the document.  For example:

```
---
type: post
status: draft
tags:
  - help
  - ruby
---

# This is a title
## This is a subtitle

This is the first paragraph.

This is another pargraph.
```

This YAML content at the top gets turned into data associated with the
document. 

```
post = Post.new("/path/to/post.md") 
post.status # => 'draft'
post.tags # => ['help','ruby']
```

The YAML data is useful, but where the brief model system really shines
is in the ability to extract data and metadata from the writing itself.

Each `Model` prescribes its own specific structure, usually
in the form of heading hierarchys (h1, h2, h3, etc). Any CSS selector
can be used against the rendered HTML produced by the markdown.  A
model can define attributes that will be extracted from the writing, for
example:

```ruby
define "Post" do
  content do
    title "h1:first-of-type"
    subtitle "h2:first-of-type"
    excerpt "p:first-of-type"

    # parses YAML blocks inside the document
    settings 'code.yaml', :serialize => true
  end
end
```

### Getting Started

```
gem install brief
brief --help
```
