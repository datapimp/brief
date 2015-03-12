require "spec_helper"

describe "Simple Files" do
  let(:doc) { Brief.testcase.releases.first }

  it "still renders simple html with no headings" do
    expect(lambda { doc.to_html }).not_to raise_error
  end
end
