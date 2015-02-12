require "spec_helper"

describe "Modifying Documents", :type => :request do
  it "lets me create new documents" do
    post "/create/epics/newly-created-epic.html.md", contents: "# Epic Title"
  end

  it "lets me update existing documents" do
    needle = rand(36**36).to_s(36)
    post "/update/concept.html.md", contents: "# Modified Content #{ needle }"
    expect(last_response.status).to eq(200)
  end

  it "lets me update just the metadata for an existing document" do
    needle = rand(36**36).to_s(36)
    post "/update/concept.html.md", data: {needle: needle}
    expect(last_response.status).to eq(200)
  end

  it "lets me remove documents" do
    post "/remove/epics/newly-created-epic.html.md"
    expect(last_response.status).to eq(200)
  end

  it "lets me run actions on documents" do
    post "/actions/custom_action/epics/epic.html.md"
    expect(last_response.status).to eq(200)
  end
end
