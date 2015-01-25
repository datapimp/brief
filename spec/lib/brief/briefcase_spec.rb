require "spec_helper"

describe "The Briefcase" do
  let(:briefcase) { Brief.testcase }

  it "has a root path" do
    expect(briefcase.root).to be_exist
  end

  it "points to a file repository" do
    expect(briefcase.repository).to be_a(Brief::Repository)
  end

  context "Model Loading" do
    it "loads the model definitions from the models folder" do
    end

    it "loads the model definitions from the DSL in the config file" do
    end
  end

  context "Document Mappings" do
    it "has all of the documents" do

    end
  end
end
