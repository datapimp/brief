require "spec_helper"

describe "The Brief Document" do
  let(:sample) do
    Brief.example_document
  end

  it "wont let me create a document outside of the briefcase" do
    expect(lambda { Brief::Document.new("/test.html.md").in_briefcase(Brief.testcase) }).to raise_error
  end
  it "creates a new doc if the path doesn't exist" do
    begin
      new_path = Brief.testcase.docs_path.join("newly-created.html.md")
      doc = Brief::Document.new(new_path)
      doc.data= {}
      doc.content= "sup"
      doc.save!

      expect(doc).to be_exist
    ensure
      FileUtils.rm_rf(new_path)
    end
  end

  it "renders html" do
    expect(sample.to_html).to match(/h1.*Features.*h1\>/)
  end

  it "renders html" do
    expect(Brief.page_document.to_html).to be_present
  end

  it "parses the html" do
    expect(sample.css("h1").length).to eq(2)
  end

  it "deserializes YAML frontmatter into attributes" do
    expect(sample.frontmatter.type).to eq("epic")
  end

  it "references the parent folder name" do
    expect(sample.parent_folder_name).to eq("epics")
  end

  it "can resolve the model type using the parent folder name if possible" do
    expect(Brief::Model.for_folder_name(sample.parent_folder_name).type_alias).to eq("epic")
  end

  context "Content Extraction" do
    it "extracts content from a css selector" do
      extracted = sample.extract_content(:args => ["h1:first-of-type"])
      expect(extracted).to eq("Blueprint Epic Example")
    end
  end

  context "defining sections" do
    it "has sections" do
      expect(sample).to be_has_sections
    end

    it "gives me info about the section headings" do
      expect(sample.section_headings).to include("features")
    end

    it "has the information from the sections" do
      expect(sample.sections_data).not_to be_empty
    end

    it "lets me define content sections" do
      expect(sample.sections).not_to be_empty
      expect(sample.sections.features).to be_present
      expect(sample.sections.features.fragment.name).to eq("section")
      expect(sample.sections.features.fragment.css("article").length).to eq(3)
    end

    it "gives me an array of items underneath the section filled with the key value mappings i laid out" do
      items = sample.sections.features.items
      expect(items.length).to eq(3)
      expect(items.map(&:components).map(&:first).uniq).to eq(["User"])
    end
  end
end
