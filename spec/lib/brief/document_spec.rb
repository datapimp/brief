require "spec_helper"

describe "The Brief Document" do
  let(:sample) do
    path = Brief.example_path.join("docs","epic.html.md")
    Brief::Document.new(path)
  end

  it "renders html" do
    expect(sample.to_html).to match(/h1.*User Stories.*h1\>/)
  end

  it "parses the html" do
    expect(sample.css("h1").length).to eq(2)
  end


  it "deserializes YAML frontmatter into attributes" do
    expect(sample.frontmatter.type).to eq("epic")
  end

  context "Content Extraction" do
    it "extracts content from a css selector" do
      extracted = sample.extract_content(:args => ["h1:first-of-type"])
      expect(extracted).to eq("Blueprint Epic Example")
    end
  end

  context "defining sections" do
    it "lets me define content sections" do
      expect(sample.sections).not_to be_empty
      expect(sample.sections.user_stories).to be_present
      expect(sample.sections.user_stories.fragment.name).to eq("section")
      expect(sample.sections.user_stories.fragment.css("article").length).to eq(3)
    end

    it "gives me an array of items underneath the section filled with the key value mappings i laid out" do
      items = sample.sections.user_stories.items
      expect(items.length).to eq(3)
      expect(items.map(&:components).map(&:first).uniq).to eq(["User"])
    end
  end
end
