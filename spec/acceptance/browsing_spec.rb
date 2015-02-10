require "spec_helper"

describe "Browsing a Briefcase REST Interface", :type => :request do
  it "should respond to requests" do
    get("/")
    expect(response.status).to eq(200)
  end
end
