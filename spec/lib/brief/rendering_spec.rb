require "spec_helper"

describe "Brief HTML Rendering" do
  let(:sample) do
    path = Brief.example_path.join("docs","epic.html.md")
    Brief::Document.new(path)
  end

  it "wraps the document with some identifying details" do
    expect(sample.to_html).to include("docs/epic.html.md")
  end

  it "wraps the higher level headings under section elements" do
    expect(sample.css("section").length).to eq(2)
  end

  it "wraps the lower level headings under article elements" do
    expect(sample.css("article").length).to eq(3)
  end

  it "nests the articles under the parent section" do
    expect(sample.css("section article").length).to eq(3)
  end
end
