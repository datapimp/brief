require "spec_helper"

describe "Rendering Attachments" do
  let(:release) { Brief.testcase.releases.first }
  let(:doc) { release.document }

  it "detects attachments" do
    expect(doc).to be_has_attachments
  end

  it "makes attachments content available" do
    expect(doc.render_attachments).not_to be_empty
  end

  it "optionally makes attachments available in the model serializer" do
    expect(release.as_json()).not_to have_key(:attachments)
    expect(release.as_json(attachments: true)[:attachments]).not_to be_empty
  end
end
