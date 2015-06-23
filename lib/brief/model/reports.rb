class Brief::GenericReport
  attr_reader :document

  def initialize(document)
    @document = document
  end

  def briefcase
    document.try(:briefcase)
  end

  def entries
    []
  end

  def headers
    []
  end
end

module Brief::Model::Reports
  def generate_report report_type
    if data.reports && data.reports.fetch(report_type, nil)
      klass = data.reports.fetch(report_type.to_s)
      klass = Object.const_get(klass) unless klass.is_a?(Class)
    else
      klass = Brief::GenericReport
    end

    klass && klass.new(self)
  end
end
