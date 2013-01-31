require 'benchmark'
require 'prover'
require 'verifier'

puts "Benchmarking time to update the prover with a new 'stream' element"


[100].each do |k|
	puts "k: #{k}"
	(50...51).step(1) do |n|
		puts "Stream Size: #{n}"
		(8...9).step(1) do |m|
			puts "Universe Size: #{m}"
			p = Prover.new(k, n, m)
			# v = Verifier.new(p.k, p.stream_bound_n, p.q, p.log_q_ceil, p.L, p.R, p.universe_size_m)

			num_elements_to_add = 100
			elements = Array.new(num_elements_to_add){ rand(p.universe_size_m) }


			Benchmark.bmbm do |x|
				(0...num_elements_to_add).each do |index|
					x.report("k:#{k}, n:#{n}, m:#{m}, num:#{num_elements_to_add}") { p.addElement(elements[index]) }

					# Reset prover
					p.labels = {}
					p.partial_labels = {}
					p.leaves = {}
				end
			end

		end # m
	end # n
end # k

