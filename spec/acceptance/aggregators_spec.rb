require "spec_helper"

describe "Document Aggregators", :type => :request do
  it "runs an aggregator on the briefcase" do
    get "/aggregator/custom_aggregator"
    expect(json["aggregator"]).to eq("custom")
  end
end
