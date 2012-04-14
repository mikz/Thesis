class Example
  attr_reader :value

  def initialize(value)
    @value = value
  end

  def truthy?
    !!@value
  end

  def falsy?
    not truthy?
  end
end
