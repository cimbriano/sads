require 'benchmark'
require 'prover'

puts "Benchmarking time to do matrix multiplications"
Benchmark.bm(10) do |x|

	(10..100).step(10) do |n|
		(10..100).step(10) do |k|

			p = Prover.new(k,n,16)
			v = Vector.elements( Array.new(p.k * p.log_q_ceil) { rand p.q })

			x.report("Matrix Mulp --  k:#{k} n:#{n}"){ 100.times { p.L * v } }
		end
	end






end