require "spec_helper"

describe "Rendering Attachments" do
  let(:doc) { Brief.testcase.releases.first }

  it "should include attachments in the serialized version" do
    expect(doc.render_attachments['test.svg']).not_to be_empty
  end
end
