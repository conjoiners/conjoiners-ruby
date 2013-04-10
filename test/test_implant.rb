require 'test/unit'
require '../lib/conjoiners.rb'

class TestImplant < Test::Unit::TestCase

  class Test
    attr_accessor :test_value
  end

  def setup
    @iyes = Test.new
    @ino = Test.new
    Conjoiners::implant(@iyes, "./conf_implant.json", "test_implant")
  end

  def test_no_implant
    @ino.test_value = "no_implant_value"
    assert_equal("no_implant_value", @ino.test_value)
  end

  def test_implant
    @iyes.test_value = "implant_value"
    assert_equal("implant_value", @iyes.test_value)
  end

end
