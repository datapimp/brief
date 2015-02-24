require "spec_helper"

describe "Packaged Apps" do
  let(:sample) do
    Brief::Briefcase.new(app: "sample")
  end

  let(:blueprint) do
    Brief::Briefcase.new(app: "blueprint")
  end

  it "should find the right path for an app name" do
    expect(Brief::Apps.path_for("blueprint")).to be_exist
  end

  it "should be using the blueprint app" do
    expect(blueprint).to be_uses_app
  end

  it "should be using the blueprint app" do
    expect(sample).to be_uses_app
  end

  it "should find the test app, and the gem apps" do
    expect(Brief::Apps.available_apps).to include("blueprint","sample")
  end
end
