require "spec_helper"

describe "Source Maps Feature" do
  let(:example) { Brief.example_document }
  let(:heading) { "A user wants to write epics" }

  it "returns the raw content under a given heading" do
    expect(example.content_under_heading(heading)).to include(heading)
  end

  it "returns the raw content under a given heading without the heading" do
    expect(example.content_under_heading(heading, false)).not_to include(heading)
  end
end
