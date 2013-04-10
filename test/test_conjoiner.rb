require 'test/unit'
require 'conjoiners'

class TestConjoiner < Test::Unit::TestCase

  class Conjoiner
    attr_accessor :test_value
  end

  def setup
    @cj1 = Conjoiner.new
    @cj2 = Conjoiner.new
    Conjoiners::implant(@cj1, "./conf_conjoiner.json", "test")
    Conjoiners::implant(@cj2, "./conf_conjoiner.json", "test2")
  end

  def test_send
    sleep 1
    @cj1.test_value = "test_value"
    sleep 1
    assert_equal("test_value", @cj2.test_value)
  end

end
