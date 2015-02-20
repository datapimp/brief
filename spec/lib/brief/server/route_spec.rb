require "spec_helper"

describe Brief::Server::Route do
  it "routes to the browse handler" do
    expect(handler_for("/browse/epics")).to eq(Brief::Server::Handlers::Browse)
  end

  it "routes to the create handler" do
    expect(handler_for("/create/epics/new.html.md")).to eq(Brief::Server::Handlers::Modify)
  end

  it "routes to the update handler" do
    expect(handler_for("/update/epics/new.html.md")).to eq(Brief::Server::Handlers::Modify)
  end

  it "routes to the remove handler" do
    expect(handler_for("/remove/epics/new.html.md")).to eq(Brief::Server::Handlers::Modify)
  end

  it "routes to the actions handler" do
    expect(handler_for("/actions/custom_action/epics/epic.html.md")).to eq(Brief::Server::Handlers::Action)
  end

  it "routes to the schema browse handler" do
    expect(handler_for("/schema")).to eq(Brief::Server::Handlers::Schema)
  end

  it "routes to the schema details handler" do
    expect(handler_for("/schema/epic")).to eq(Brief::Server::Handlers::Schema)
  end

  it "routes to the view content handler" do
    expect(handler_for("/view/content/epics/epic.html.md")).to eq(Brief::Server::Handlers::Show)
  end

  it "routes to the view rendered handler" do
    expect(handler_for("/view/rendered/epics/epic.html.md")).to eq(Brief::Server::Handlers::Show)
  end

  it "routes to the view details handler" do
    expect(handler_for("/view/details/epics/epic.html.md")).to eq(Brief::Server::Handlers::Show)
  end
end
