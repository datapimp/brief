require "spec_helper"

describe "The Page Document Type" do
  let(:page) { Brief.page_document.model_class }
  let(:concept) { Brief::Concept }

  it "should return the example because there's no prompt defined" do
    expect(page.writing_prompt).to eq page.example_body
  end

  it "should return whatever is defined in the prompt dsl" do
    expect(concept.writing_prompt).to eq "asdf"
  end
end
