class Brief::Persona
  include Brief::Model

  content do
    msg "[data-random-attr='value']"
    rando "#rando code", :serialize => :yaml
  end
end
