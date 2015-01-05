require "spec_helper"

describe "The Brief Document" do
  let(:sample) do
    path = Brief.example_path.join("docs","epic.html.md")
    Brief::Document.new(path)
  end

  it "renders html" do
    expect(sample.to_html).to include("<h1>User Stories</h1>")
  end

  it "parses the html" do
    expect(sample.css("h1").length).to eq(2)
  end

  it "deserializes YAML frontmatter into attributes" do
    expect(sample.frontmatter.type).to eq("epic")
  end

  context "Content Extraction" do
    it "extracts content from a css selector" do
      extracted = sample.extract_content(:args => ["h1:first-child"])
      expect(extracted).to eq("Blueprint Epic Example")
    end
  end
end
