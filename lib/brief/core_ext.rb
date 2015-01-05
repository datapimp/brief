class Hash
  def to_mash
    Hashie::Mash.new(self)
  end
end

class String
  def to_pathname
    Pathname(self)
  end
end
