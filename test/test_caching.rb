require 'helper'
require 'prover'

class TestCaching < MiniTest::Unit::TestCase

describe "Caching Behavior of Partial Labels" do
	before do
		@prover = Prover.new(5,10,8)
	end

	describe "Prover should have empty partial label storage" do
		# @prover.partial_labels.wont_be_nil
	end

end # main describe

end # TestCaching