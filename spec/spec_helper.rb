require 'pry'
require 'rack/test'
require 'brief'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

module Brief
  def self.spec_root
    Pathname(File.dirname(__FILE__))
  end

  def self.example_path
    testcase.root
  end

  def self.concept_document
    path = Brief.example_path.join("docs","concept.html.md")
    testcase.document_at(path)
  end

  def self.page_document
    path = Brief.example_path.join("docs","page.html.md")
    testcase.document_at(path)
  end

  def self.example_document
    path = Brief.example_path.join("docs","epics","epic.html.md")
    testcase.document_at(path)
  end

  def self.testcase
    @example ||= Brief::Briefcase.new(root:spec_root.join("fixtures","example"))
  end
end

RSpec.configure do |config|
  config.mock_with :rspec
  config.include Rack::Test::Methods
  config.include TestHelpers

  config.after(:suite) do
    `git checkout spec/fixtures/example/docs` rescue nil
  end
end

ENV['BRIEF_APPS_PATH'] = Brief.spec_root.join("fixtures","apps").to_s
