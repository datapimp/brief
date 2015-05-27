require "spec_helper"


describe "The Configuration DSL" do
  let(:briefcase) { Brief.testcase }

  it "can create methods on our models" do
    expect(briefcase.features.first.defined_helper_method).to eq(true)
  end

  it "treats actions as available commands" do
    expect(Brief::Epic.defined_actions).to include(:custom_action)
  end

  it "doesnt treat helpers as available commands" do
    expect(Brief::Epic.defined_helper_methods).to include(:features)
    expect(Brief::Epic.defined_actions).not_to include(:features)
  end
end
