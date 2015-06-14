require "spec_helper"

describe "Content Transformation" do
  let(:outline) { Brief.testcase.document_at("index.md") }
  let(:wireframe) { Brief.testcase.document_at("wireframe.html.md") }

  it "transforms the link tags based on the DSL" do
    html = outline.to_html
    expect(html).to include("Blueprint Persona Example")
    expect(html).to include("brief://")
  end

  it "automatically inlines SVG content for us" do
    html = wireframe.to_html
    expect(html).to include("svg-wrapper")
    expect(html).to include("svg version")
  end

  describe "HREF Generation" do
    it "does nothing by default" do
      expect(Brief.testcase.get_href_for("brief://me")).to eq("brief://me")
    end
  end
end


