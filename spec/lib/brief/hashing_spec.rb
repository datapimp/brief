require "spec_helper"

describe "Hashing" do
  let(:doc) { Brief.concept_document }

  it "has a content hash" do
    expect(doc.content_hash).not_to be_empty
  end

  it "has a file system hash" do
    expect(doc.file_hash).not_to be_empty
  end

  it "detects when it is stale" do
    new_content = doc.content += "\n\n1";
    doc.path.open("w+") {|fh| fh.write("---\ntype: concept\n\n---\n\n#{new_content}") }
    expect(doc).to be_content_stale
  end

  it "refreshes itself if stale" do
    new_content = doc.content += "\n\n1";
    doc.path.open("w+") {|fh| fh.write("---\ntype: concept\n\n---\n\n#{new_content}") }
    expect(doc).to be_content_stale
  end

end
