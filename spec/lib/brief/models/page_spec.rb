require "spec_helper"

describe "The Page Document Type" do
  let(:page) { Brief.page_document.to_model }

  it "should have content" do
    expect(page.to_html).to include("Summary")
  end

  it "should have the paragraph" do
    expect(page.paragraph).not_to be_nil
  end

  it "should have the right extracted content data" do
    expect(page.extracted_content_data.title).to eq("Summary")
    expect(page.extracted_content_data.paragraph).not_to be_nil
  end
end

