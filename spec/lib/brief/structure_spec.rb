require "spec_helper"

describe "Document Structure Information" do
  let(:sample) do
    path = Brief.example_path.join("docs","epic.html.md")
    Brief::Document.new(path)
  end

  it "should put the line numbers on the headings" do
    el = sample.css("h1").first
    expect(el.attr('data-line-number')).to eq("8")
  end

end


