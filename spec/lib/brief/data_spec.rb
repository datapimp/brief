require "spec_helper"

describe "Brief Data Wrapper" do
  let(:briefcase) { Brief.testcase }

  it "lets me query the items data" do
    expect(briefcase.data.items.where(status: "inactive").length).to eq(1)
  end

  it "lets me query the items data" do
    expect(briefcase.data.items.where(status: "active").length).to eq(2)
  end

  it "gives me the data" do
    expect(briefcase.data.items.length).to eq(3)
  end
end
