### 1.0.0

Rewrite.  

- New style for structure definition

  Instead of parsing markdown prior to rendering it in order to
  determine the structure, I've taken a new approach where I render the markdown into HTML and then use Nokogiri.

  This means I don't even really have to parse the markdown, I can just
  let the user tell us how the documents are structured using CSS
  selectors.

  In addition to this, I've added a DSL that lets a user declare the model
attributes.

- Documents and Models

  Documents are just YAML frontmatter and markdown.

  Each document can be represented in model form. 

  The `Brief::Model` is an ActiveModel like object.

### 1.1.0 

- Introducing Briefcases

  Briefcases are top level folders which contain model definition code
  and configuration, and a hierarchy of subfolders each containing
  markdown documents which will map to models.

- Model Definition DSL

  Briefcases can have more than one model class.  These models can have
  attributes, and can specify structure rules which allow for the
  document to be parsed in a semantic way.

### 1.2.0

- Introducing Document Sections 
  - Added `define_section` to the model definition DSL. This will allow certain headings to be used to access a 
    section of the document in isolation. 
    
    Document sections have their own mini-structure, and will 
    contain at least one, usually more than one repeatable pattern.

    These repeatable patterns will usually contain short-hand
    references to other documents, or key attributes that can be used to
    create other documents.

    Document sections are how one document can be broken apart into many
    other documents.

- CLI Actions
  - Added `actions` to the method definition DSL. This will allow a model instance to define a method, and
    then dispatch calls to this method from the Brief CLI interface.

- Changed HTML rendering
  - using a custom redcarpet markdown renderer in order to include
    data-attributes on heading tags
  - rendered html retains line number reference to the source markdown

### 1.3.0

- Introducing Templates

  - Templates are ERB strings that can be associated with models. This
    will convert a data structure into the appropriate markdown, so that
    it can be persisted as a `Brief::Document` and do everything a
    normal doc can.

- Introducing Examples

  - Each model class can point to an example, or include example content
    inline as a string.

- Introducing the 'write' command.

  The brief CLI will have a write command for each model, which 
  will open up $EDITOR and load the example content for a model

  so for example, given a model:

  ```
  define "User Story" do

  example <<- EOF
  ---
  type: user_story
  status: draft
  ---

  # User story example
  
  As a **user** I would like to **do this thing** so that I can
  **achieve this goal**
  EOF
  end
  ```

  When I run this on the command line:

  ```bash
  brief write user story
  ```

  then it will open up $EDITOR

### 1.3.2

- Various performance fixes
- Model package loading system foundation

### 1.4.0

- Brief::Server provides a REST interface to a briefcase
- Brief::Server::Gateway provdies a REST wrapper around a folder of
  briefcases
