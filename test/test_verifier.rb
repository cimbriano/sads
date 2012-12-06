require 'helper'
require 'verifier'


class TestVerifier < MiniTest::Unit::TestCase

describe "Verifier" do

	before do
		@ver = Verifier.new(1,2,3,4,5,6)
	end

	def test_constructor
		assert(!@ver.nil?, "Verifier not constructed")
	end

	def test_mod
		ans = @ver.send(:mod, 8, 2)
		assert_equal(0, ans, "Mod not working")
	end

	def test_has_correct_fields
		assert(@ver.respond_to?(:L))
		assert(@ver.respond_to?(:R))
		assert(@ver.respond_to?(:root_digest))
	end


end # describe verifier
end