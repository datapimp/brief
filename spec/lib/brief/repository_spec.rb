require "spec_helper"

describe "The Brief Document Repository" do
  let(:repository) { Brief.example.repository }

  it "has a bunch of documents" do
    expect(repository.documents).not_to be_empty
  end

  context "querying api" do
    it "finds the first document matching a query" do
      query = repository.where(state:"active")
      expect(query.first.type).to eq("epic")
    end

    it "finds the last document matching a query" do
      query = repository.where(state:"active")
      expect(query.last.type).to eq("user_story")
    end

    it "respects the ordering" do
      types = repository.order_by(:type).map(&:type)
      expect(types.first).to eq("concept")
      expect(types.last).to eq("wireframe")

      types = repository.order_by(:type => :desc).map(&:type)
      expect(types.last).to eq("concept")
      expect(types.first).to eq("wireframe")
    end

    it "supports different operators" do
      query = repository.where(:type.neq => "epic")
      expect(query.length).to eq(6)
    end

    it "limits the results to the specified size" do
      query = repository.where(:type.neq => "epic").limit(3)
      expect(query.length).to eq(3)
    end

    it "allows me to use an offset" do
      one = repository.where(:type.neq => "epic").limit(3).offset(1).map(&:type).to_set
      two = repository.where(:type.neq => "epic").limit(3).offset(2).map(&:type).to_set
      expect(one).not_to eq(two)
    end

    it "can filter documents by their attributes" do
      query = repository.where(state:"active")
      expect(query.length).to eq(2)
      query = repository.where(title:"Blueprint Epic Example")
      expect(query.length).to eq(1)
    end

    it "returns empty result set when nothing matches" do
      query = repository.where(type:"some bullshit")
      expect(query.length).to eq(0)
    end
  end

end
