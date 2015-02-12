require "spec_helper"

describe "Briefcase Document Schema", :type => :request do
  it "gives me information about the schema" do
    get("/schema")
    expect(last_response.status).to eq(200)
  end

  it "gives me information about a document type" do
    get("/schema/epic")
    expect(last_response.status).to eq(200)
  end
end
