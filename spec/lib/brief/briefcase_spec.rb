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
      expect(Brief::Model.classes.length).to eq(2)
    end

    it "loads the model definitions from the DSL in the config file" do
      expect(Brief::Model.classes.length).to eq(2)
    end

    it "caches the output" do
      object_id = briefcase.epics.object_id
      expect(briefcase.epics.object_id).to eq(object_id)
    end
  end

  context "Document Mappings" do
    it "has all of the documents" do
      expect(briefcase.epics.length).to eq(1)
      expect(briefcase.documents.length).to eq(7)
    end
  end
end
