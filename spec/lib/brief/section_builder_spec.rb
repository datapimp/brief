require "spec_helper"

describe "The Section Builder" do
  let(:builder) do
    inputs = [
      [1, ["<section><h1>Heading</h1></section>"]],
      [1, ["<section><h1>Section Heading</h1></section>"]],
      [2, ["<article><h2>a</h2></article>"]],
      [2, ["<article><h2>b</h2></article>"]],
      [2, ["<article><h2>c</h2></article>"]],
      [1, ["<section><h1>Footer</h1></section>"]]
    ]

    Brief::Document::Section::Builder.new(inputs)
  end

  it "collapses the HTML into sections for us" do
    expect(builder.to_fragment.css("section h1").count).to eq(3)
    expect(builder.to_fragment.css("section article").count).to eq(3)
  end

end
