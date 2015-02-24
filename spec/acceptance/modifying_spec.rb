require "spec_helper"

describe "Modifying Documents", :type => :request do
  it "lets me create new documents by passing data and content" do
    begin
      post "/create/epics/newly-created-epic.html.md", content: "# Epic Title"
      expect(json["path"]).to be_present
      expect(json["path"].to_pathname).to be_exist
      expect(last_response.status).to eq(200)
    ensure
      doc = Brief.case.docs_path.join("epics","newly-created-epic.html.md")
      doc.unlink if doc.exist?
    end
  end

  it "lets me create documents passing raw yaml and content" do
    begin
      needle = rand(36**36).to_s(36)
      data = {newly: needle, type: "epic"}.to_yaml
      post "/create/epics/newly-created-epic-raw.html.md", raw: "#{ data }\n---\n\n# Epic Title"
      doc = Brief::Document.new(Brief.case.docs_path.join("epics","newly-created-epic-raw.html.md"))
      expect(doc.path.read).to include(needle)
      expect(last_response.status).to eq(200)
    ensure
      doc = Brief.case.docs_path.join("epics","newly-created-epic-raw.html.md")
      doc.unlink if doc.exist?
    end
  end

  it "lets me update existing documents" do
    needle = rand(36**36).to_s(36)
    post "/update/concept.html.md", content: "# Modified Content #{ needle }"
    doc = Brief.case.document_at("concept.html.md")
    expect(doc.content).to include(needle)
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
