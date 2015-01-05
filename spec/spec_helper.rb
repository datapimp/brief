require 'pry'
require 'brief'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

module Brief
  def self.spec_root
    Pathname(File.dirname(__FILE__))
  end

  def self.example_path
    example.root
  end

  def self.example
    @example ||= Brief::Briefcase.new(root:spec_root.join("fixtures","example"))
  end
end

RSpec.configure do |config|
  config.mock_with :rspec
  #config.order = "random"
end
