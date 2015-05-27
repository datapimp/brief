require "spec_helper"

describe "The Brief Model" do
  let(:briefcase) { Brief.testcase }
  let(:epic) { briefcase.epics.first }
  let(:feature) { briefcase.features.first }

  it "exposes information about its schema" do
    expect(epic.class.to_schema.keys).to include(:schema, :name, :class_name, :type_alias)
  end

  context "DSL Style Declarations" do
    it "picks up a definition of 'Feature'" do
      expect(briefcase.model("Feature")).to be_present
    end

    it "defines a class for us" do
      expect((Brief::Model::Feature rescue nil)).to be_present
    end

    it "shows up in the model definitions table" do
      expect(Brief::Model.table.feature).to be_present
    end

    it "has a definition" do
      expect(Brief::Model::Feature.definition).to be_a(Brief::Model::Definition)
    end

    it "has paths and document attributes by default" do
      set = Brief::Model::Feature.attribute_set.map(&:name)
      expect(set).to include(:path, :document)
    end

    it "has the attributes defined in the DSL" do
      set = Brief::Model::Feature.attribute_set.map(&:name)
      expect(set).to include(:title, :status, :epic_title)
    end

    it "has attribute setters" do
      story = Brief::Model::Feature.new
      expect(story).to respond_to(:title=)
    end
  end

  context "Class Definitions" do
    it "picks up a defintion of 'Epic'" do
      expect((Brief::Epic rescue nil)).to be_present
    end

    it "shows up in the model definitions table" do
      expect(Brief::Model.table.epic).to be_present
    end

    it "has a definition" do
      expect(Brief::Epic.definition).to be_a(Brief::Model::Definition)
    end

    it "has paths and document attributes by default" do
      set = Brief::Epic.attribute_set.map(&:name)
      expect(set).to include(:path, :document)
    end

    it "has the attributes defined inline in the class methods" do
      set = Brief::Epic.attribute_set.map(&:name)
      expect(set).to include(:path, :document, :title, :status)
    end

    it "has attribute setters" do
      epic = Brief::Epic.new
      expect(epic).to respond_to(:title=)
      expect(epic).to respond_to(:subheading=)
    end
  end

  context "Briefcase Finders" do
    it "creates methods on the briefcase for each class" do
      expect(briefcase.epics).not_to be_empty
      expect(briefcase.features).not_to be_empty
    end

    it "finds instances of the desired model" do
      expect(briefcase.epics.first).to be_a(Brief::Epic)
    end
  end

  context "Document Content Extraction" do
    it "has a relationship to the underlying document" do
      expect(epic.document).to be_a(Brief::Document)
    end

    it "has a content extractor" do
      expect(epic.extracted).to be_a(Brief::Document::ContentExtractor)
    end

    it "uses the configured content extractor settings" do
      expect(epic.extracted.title).to eq("Blueprint Epic Example")
    end
  end

  context "Actions and Helpers" do
    it "uses the actions block to define CLI dispatchers" do
      expect(epic.class.defined_actions).to include(:custom_action)
    end

    it "users the actions block to define CLI dispatchers (dsl)" do
      expect(feature.class.defined_actions).to include(:custom_action)
    end

    it "lets me define a helper method which utilizes all the extracted data and content structure" do
      expect(epic.features.length).to eq(3)
      expect(epic.features.map(&:persona)).to include("User")
    end
  end

  context "Section Mappings" do
    it "defines a section mapping for Features" do
      mapping = epic.class.section_mapping("Features")
      expect(mapping).to be_a(Brief::Document::Section::Mapping)
    end
  end
end
