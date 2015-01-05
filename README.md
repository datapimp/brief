# Brief

Brief is a framework for developing applications geared toward 
writers who would like to build structure and automation on top of 
collections of markdown documents.

A Brief Document is a markdown file which has a YAML header which
contains metadata about the document, and at the same time Brief
Document types can define a heading structure or hierarchy which allows
the documents themselves to be queried and for data to be extracted from
them.

This is a great way to build applications whose primary interface is the
text editor, allowing writing and thought to flow as freely as possible
and to later be used to power some automation tasks.

For example:

```markdown
---
type: thoughtleader_profile 
name: Devops Thoughtleaders 
subject: devops
---

Devops is good.  Devops is awesome.

# Thoughtleaders

## Jon Hendren
- twitter: @fart
- website: http://jonhendren.com
- github: fart 

## Jon Soeder
- twitter: @soederpop
- website: http://soederpop.com
- github: datapimp
```

In the above example, we've written a simple text file for a document
that we call a 'Thoughtleader Profile'.  We may have a folder of these
documents, where each one has a different subject, such as 'Email
Marketing' or 'Ruby on Rails Development' and each of those documents
will list the Thoughtleaders and their twitter profiles, websites,
github, or whatever.

Brief will allow us to do something like:

```ruby
case = Brief::Case.new(root: "/path/to/files")

case.thoughtleader_profiles.map(&:subject) # => ["devops", "ruby on rails", "e-mail marketing"]

profile = case.find_thoughtleader_profile_by_subject("devops")

profile.thoughtleaders.map(&:name) #=> ["Jon Hendren", "Jon Soeder"]
```

With each of these documents, we might want to constantly monitor the
output and contributions of these two fine men named Jon, and be
automatically notified when they release somethign new.  The possibilities are really endless, and up to you.

### Example Application

The `architects` gem uses `brief` as the basis for an application called
a blueprint.  A blueprint is a collection of written documents about
many different aspects of software design and project planning. 

The blueprint allows us to write `Epics` which are a collection of `User
Stories` which get estimated, scheduled, and planned for a `Release`.  A
`Release` is a collection of `User Stories` which have been delivered
and which have a corresponding 'Integration Test'.

Brief allows us to write all of these things in a markdown file very
quickly, and develop automation tasks which let us do things like
publish all of the `User Stories` into Github Issues .

The way we accomplish this is by using Brief Models.

### Brief Models

A Model is created from a structured Brief Document which gets parsed,
and the metadata attributes, and information that gets
derived from the document's structure, gets turned into data.

You can define models very easily:

```
Brief.define("User Story") do
  attribute :title, String
  attribute :estimate, Integer
  attribute :assigned_to, String
  attribute :status, String
  attribute :github_issue_number, Integer
  attribute :github_milestone_number, Integer
  attribute :epic, Brief.models("Epic")
end
```

