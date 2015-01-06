require "spec_helper"


describe "The Configuration DSL" do
  let(:briefcase) { Brief.example }

  it "can create methods on our models" do
    expect(briefcase.user_stories.first.defined_helper_method).to eq(true)
  end
end
