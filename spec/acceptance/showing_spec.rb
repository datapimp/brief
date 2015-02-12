require "spec_helper"

describe "Viewing a Briefcase Document", :type => :request do
  it "shows the document content" do
    get("/view/content/epics/epic.html.md")
    expect(last_response.status).to eq(200)
  end

  it "shows the rendered version of the document" do
    get("/view/rendered/epics/epic.html.md")
    expect(last_response.status).to eq(200)
  end

  it "shows the rendered version of the document json" do
    get("/view/details/epics/epic.html.md")
    expect(last_response.status).to eq(200)
  end
end
