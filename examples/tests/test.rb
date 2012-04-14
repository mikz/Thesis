require 'minitest/autorun'

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

class TestExample < MiniTest::Unit::TestCase
  def setup
    @value = "value"
    @example = Example.new(@value)
  end

  def test_value_will_return_value
    assert_equal @value, @example.value
  end

  def test_it_is_truthy
    assert @example.truthy?
  end

  def test_it_isnt_falsy
    refute @example.falsy?
  end
end
