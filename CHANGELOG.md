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
