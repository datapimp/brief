require "spec_helper"

describe "Browsing a Briefcase REST Interface", :type => :request do
  it "responds to requests" do
    get "/"
    expect(last_response.status).to eq(200)
  end

  it "shows me all of the documents for the requested type" do
    get "/browse/epics"
    expect(json).to be_a(Array)
    expect(json.first).to be_a(Hash)
    expect(last_response.status).to eq(200)
  end
end
