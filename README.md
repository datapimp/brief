# Brief 
[![Build
Status](https://travis-ci.org/datapimp/brief.svg?branch=master)](https://travis-ci.org/datapimp/brief)

### Turning writers into object oriented programmers 

Brief lets writers build applications on top of collections of markdown files.  Brief lets you define different classes or types of documents, called `Model`s which are responsible for defining certain writing conventions that apply to a group of documents.

When documents conform to these conventions, it is possible to treat them as software entities with attributes, and give the documents and their content unique identities that can be mapped to other parts of the software systems we work with every day. 

### Turn documents into data 

The most basic way of combining writing with data, is through the use of YAML Frontmatter as metadata for the document.  For example:

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

This YAML content at the top gets turned into data associated with the document. 

```
post = Post.new("/path/to/post.md") 
post.status # => 'draft'
post.tags # => ['help','ruby']
```

The YAML data is useful, but where the brief model system really shines is in the ability to extract data and metadata from the writing itself.

Each `Model` prescribes its own specific structure, usually in the form of heading hierarchys (h1, h2, h3, etc). Any CSS selector can be used against the rendered HTML produced by the markdown.  A model can define attributes that will be extracted from the writing, for example:

```ruby
define "Recipe" do
  content do
    title "h1:first-of-type"
    subtitle "h2:first-of-type"
    excerpt "p:first-of-type"

    # parses YAML blocks inside the document
    settings 'code.yaml', :serialize => true

    define_section("Ingredients") do
      each("li").is_a(:ingredient).has(:name=>"li")
    end

    define_section("Steps") do
      each("li").is_a(:step).has(:description=>"li")
    end

    helpers do
      def ingredient_names
        sections.ingredients.items.map(&:name)
      end

      def have_inventory?
        !ingredient_names.detect {|ingredient| inventory[ingredient].to_i <= 0 }
      end
    end
  end
end

define "Ingredient" do
  content do
    title "h1:first-of-type"
    summary "p:first-of-type"

    define_section("Vendors") do
      each("h2").is_a(:vendor).has(:title=>"h2",:website=>"a:first-of-type")
    end
  end

  helpers do
    def vendor_websites
      sections.vendors.items.map(&:website)
    end
  end
end
```

### Document Structure 

Brief works by processing the markdown that is rendered by default, and building a hierarchal structure based on the headings you use. A `Brief::Model` can be assigned to a certain folder of documents, and if all of those documents follow the same heading structure, you can 
interact with the documents as data structures and treat them as relatable entities in your object oriented software system.  

This opens up writing as a possible user interface for a number of
systems.  

That is powerful stuff.

### Getting Started

```
gem install brief
brief --help
```

### Structure of a Briefcase

- `docs/` contain diferent markdown files with YAML frontmatter.
- `models/` define your own model classes.
- `data/` dump data sources as JSON in here to use them in the renderer 
- `assets/` you can include / reference assets like PNG or SVG images
- `brief.rb` the brief config file

### Servers

Brief ships with a number of different "servers" which can sit on top of
a single `briefcase` or a folder with a bunch of different briefcases.

These servers provide an interface for common things like searching a
collection of documents, rendering documents, or adding,editing,removing
documents.

Currently there is a standard REST interface, and a Websockets
interface.

### Apps

The brief gem ships with a couple of `apps`.  These `apps` are
collections of models and represent a sample application you can use.

You can use an `app` by saying so in your config file:

```ruby
# brief.rb
use "blueprint" # => $BRIEF_GEM/apps/blueprint
```

## Other neat features (TODO)

### Special Link & Image Tags

You can include the content from other documents pretty easily

  ```markdown
  [include:content](path=feature.html.md)
  ```

- You can inline SVG assets pretty easily:

  ```markdown
  ![inline:svg](path=diagrams/test.svg)
  ```
