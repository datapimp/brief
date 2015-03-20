Dir[File.join(Dir.pwd, 'tasks', '**', '*.rb')].each { |f| require f }

require 'digest'
require 'octokit'
require 'pathname'

module Distribution
  class Release
    extend Forwardable
    include PackageHelpers

    attr_reader :tarball, :github, :package

    def_delegators :@tarball, :package, :version, :file

    def initialize(tarball)
      @tarball = tarball
      @github = Octokit::Client.new access_token: ENV['OCTODOWN_TOKEN']
    end

    def self.create(tarball)
      release = new(tarball)
      release.create_new_release
    end

    def create_new_release
      print_to_console 'Publishing release to GitHub...'
      github.create_release(
        'datapimp/brief',
        "v#{version}",
        name: "v#{version}",
        body: ReleaseNotes.new.content
      )
    end

    def upload_asset
      print_to_console 'Uploading to GitHub...'
      github.upload_asset find_upload_url, file
    end

    private

    def find_upload_url
      Octokit.releases('datapimp/brief').find do |n|
        n.tag_name == "v#{version}"
      end[:url]
    end
  end
end
