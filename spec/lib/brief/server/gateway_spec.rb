require "brief/server/gateway"
require "spec_helper"

describe "Briefcase Server Gateway" do
  let(:gateway) do
    Brief::Server::Gateway.new(root: Brief.spec_root.join("fixtures"))
  end

  it "routes requests to briefcase projects inside a folder" do
    response = gateway.call(env_for("/briefcases/example/browse/epics"))
    status, headers, body = response
    json = JSON.parse(response.last.first)

    expect(status).to eq(200)
    expect(headers["Access-Control-Allow-Origin"]).to eq("*")
    expect(json.length).to eq(2)
  end
end
