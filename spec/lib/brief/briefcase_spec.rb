require "spec_helper"

describe "The Briefcase" do
  let(:briefcase) { Brief.testcase }

  it "has a root path" do
    expect(briefcase.root).to be_exist
  end

  it "has a cache key" do
    expect(briefcase.cache_key).not_to be_nil
  end

  it "has a slug" do
    expect(briefcase.slug).to eq("example")
  end

  it "has settings" do
    expect(briefcase.settings).not_to be_empty
  end

  it "has a table of contents" do
    expect(briefcase.table_of_contents).to be_present
    expect(briefcase.table_of_contents.headings).not_to be_empty
  end

  it "points to a file repository" do
    expect(briefcase.repository).to be_a(Brief::Repository)
  end

  it "defines methods which combine models in arbitrary ways" do
    expect(briefcase.custom_aggregator).to be_a(Hash)
  end

  it "reads the settings.yml" do
    expect(briefcase.settings.settings).to be_present
  end

  # Need to improve this
  context "Model Loading" do
    it "loads the model definitions from the models and the apps folder" do
      expect(Brief::Model.classes).not_to be_empty
    end

    it "loads the model definitions from the DSL in the config file" do
      expect(Brief::Model.classes).not_to be_empty
    end

    it "caches the output" do
      object_id = briefcase.epics.object_id
      expect(briefcase.epics.object_id).to eq(object_id)
    end
  end

  context "Document Mappings" do
    it "has all of the documents" do
      expect(briefcase.epics.length).to eq(1)
      expect(briefcase.documents.length).to be_greater_than(9)
    end
  end
end
