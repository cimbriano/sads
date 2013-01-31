require 'benchmark'
require 'prover'

puts "Benchmarking time to do Ruby matrix multiplications"
Benchmark.bm(7) do |x|

	(10..20).step(10) do |n|
		(10..20).step(10) do |k|

			p = Prover.new(k,n,16)
			v = Vector.elements( Array.new(p.k * p.log_q_ceil) { rand p.q })

			x.report("k:#{k} n:#{n}"){ 100.times { p.L * v } }
		end
	end
end