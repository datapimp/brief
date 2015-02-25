require "spec_helper"

describe "Serializing From Docs" do
  let(:page) {
    Brief.testcase.pages.first
  }

  it "should serialize the yaml" do
    expect(page.yaml_data.nested).to eq("structure")
  end
end
