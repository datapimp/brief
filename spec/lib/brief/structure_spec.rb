require "spec_helper"

describe "Document Structure Information" do
  let(:sample) do
    Brief.example_document
  end

  let(:one) do
    path = Brief.spec_root.join("fixtures","structures", "one.html.md")
    Brief::Document.new(path)
  end

  let(:two) do
    path = Brief.spec_root.join("fixtures","structures", "two.html.md")
    Brief::Document.new(path)
  end

  let(:three) do
    path = Brief.spec_root.join("fixtures","structures", "three.html.md")
    Brief::Document.new(path)
  end

  context "Mapping markdown source to output html" do
    it "should put the line numbers on the headings" do
      el = sample.css("h1").first
      expect(el.attr('data-line-number')).to eq("8")
    end
  end
end
