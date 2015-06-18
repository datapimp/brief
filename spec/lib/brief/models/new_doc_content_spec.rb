require "spec_helper"

describe "The Page Document Type" do
  let(:page) { Brief.page_document.model_class }
  let(:concept) { Brief::Concept }

  it "should have some example content" do
    expect(page.example_content).not_to be_empty
  end

  it "should return the example because there's no new_doc_template defined" do
    expect(page.new_doc_template).to eq page.example_content
  end

  it "should return whatever is defined in the new_doc_template dsl" do
    expect(concept.new_doc_template).to eq "The concept new doc template"
  end

  it "should return the default document name because there's no new_doc_name defined" do
    expect(page.new_doc_name).to eq "page-2015-06-17.md"
  end

  it "should return the new document name if new_doc_name is defined" do
    expect(concept.new_doc_name).to eq "somecustomname.md"
  end
end
