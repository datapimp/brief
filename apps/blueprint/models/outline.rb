class Brief::Apps::Blueprint::Outline
  include Brief::Model

  meta do
    type
  end

  content do
    settings "code.yaml:first-of-type", :serialize => :yaml, :hide => true
  end
end
