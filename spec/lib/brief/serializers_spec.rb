require "spec_helper"

describe "Serializing From Docs" do
  let(:page) {
    Brief.testcase.pages.first
  }

  it "should serialize the yaml" do
    binding.pry
    expect(page.yaml.nested).to eq("structure")
  end
end
