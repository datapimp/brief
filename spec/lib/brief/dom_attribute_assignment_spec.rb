require "spec_helper"

describe "DOM Attribute Assignment" do
  let(:doc) { Brief.persona_document  }
  let(:model) { doc.to_model }

  it "should make targeting elements easier" do
    expect(doc.css('#rando code').text).not_to be_empty
  end

  it "should assign attributes to the headings" do
    expect(doc.css('[data-random-attr="value"]').length).to eq(1)
  end

  it "should not include the attribute syntax in the text" do
    expect(doc.css('h2').text).to eq('Random Heading')
  end
end
