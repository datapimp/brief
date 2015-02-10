module Requests
  module JsonHelpers
    def app
      @app ||= Brief.testcase.server
    end

    def json
      @json ||= JSON.parse(response.body)
    end
  end
end
