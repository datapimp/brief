require "spec_helper"

describe "Document Reports" do
  it "should be able to generate reports using custom report classes" do
    sample = Brief.testcase.releases.first
    report = sample.generate_report(:sample)
    expect(report.entries).to include(sample.title)
  end
end
