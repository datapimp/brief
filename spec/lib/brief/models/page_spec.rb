require "spec_helper"

describe "The Page Document Type" do
  let(:page) { Brief.page_document.to_model }

  it "should have content" do
    expect(page.to_html).to include("Summary")
  end
end

