require "spec_helper"

describe "Document Templates" do
  let(:data) do
    {
      title: "Epic Example",
      status: "published",
      type: "epic",
      user_stories:[{
        title: "A user wants to do something",
        paragraph: "As a user I would like to do something so that I can succeed",
        goal: "I can succeed",
        persona: "user",
        behavior: "do something"
      },{
        title: "A user wants to do something else",
        paragraph: "As a user I would like to do something else so that I can succeed"
      }]
    }
  end

  it "has template body" do
    expect(Brief::Epic.template_body).not_to be_empty
  end

  it "has an example" do
    expect(Brief::Epic.example_body).not_to be_empty
  end

  it "takes a hash of data and renders yaml frontmatter" do
    expect(Brief::Document.create_from_data(data).title).to eq("Epic Example")
  end

  it "supports more complex renderings" do
    doc = Brief::Document.create_from_data(data)
    content = doc.content

    expect(content).to include("# User Stories")
    expect(content).to include("# Epic Example")
    expect(content).to include("## A user wants to do something")
    expect(content).to include("## A user wants to do something else")
  end

end
