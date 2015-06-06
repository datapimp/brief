class Brief::Page
  include Brief::Model

  meta do
    title
  end

  content do
    title "h1:first-of-type"
    paragraph "p:first-of-type"
    yaml_data "pre[lang='yaml'] code", :serialize => :yaml
    yaml "pre[lang='yaml'] code", :serialize => :yaml
  end
end

__END__

@@ example
---
  type: page
  title: Example Page
---

# This is the title of the page

this is the first paragraph

## other heading

below is some yaml.  you can embed data under a heading, if it is relevant to that heading.

```yaml
setting: value
```

@@ template

<% if object.title %>
# <%= object.title %>
<% end %>
