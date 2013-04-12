require 'test/unit'
require 'conjoiners'

class TestReact < Test::Unit::TestCase

  class Test
    attr_accessor :test_value
    attr_reader :result
    def onTransenlightenment
      @result = @test_value.to_i + 1
    end
  end

  def setup
    @cj1 = Test.new
    @cj2 = Test.new
    Conjoiners::implant(@cj1, "test/conf_react.json", "test")
    Conjoiners::implant(@cj2, "test/conf_react.json", "test2")
  end

  def test_send
    sleep 1
    @cj1.test_value = 1
    sleep 1
    assert_equal(2, @cj2.result)
  end

end
