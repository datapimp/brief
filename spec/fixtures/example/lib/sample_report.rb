class SampleReport < Brief::GenericReport
  def entries
    [document.title]
  end
end
