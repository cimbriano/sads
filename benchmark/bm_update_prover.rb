require 'benchmark'
require 'prover'
require 'verifier'

puts "Benchmarking time to update the prover with a new 'stream' element"


[100].each do |k|
	puts "k: #{k}"
	(50...51).step(1) do |n|
		puts "Stream Size: #{n}"
		(200...1000).step(200) do |m|
			puts "Universe Size: #{m}"
			p = Prover.new(k, n, m)
			# v = Verifier.new(p.k, p.stream_bound_n, p.q, p.log_q_ceil, p.L, p.R, p.universe_size_m)

			# Pre-generate random elements to add to the prover
			num_elements_to_add = 100
			elements = Array.new(num_elements_to_add){ rand(p.universe_size_m) }

			# Obtain references to provers internal objects
			labels = p.labels
			p_labels = p.partial_labels
			leaves = p.leaves


			Benchmark.bmbm do |x|
				(0...num_elements_to_add).each do |index|
					x.report("k:#{k}, n:#{n}, m:#{m}, ele added:#{num_elements_to_add}") { p.addElement(elements[index]) }

					# Reset prover storage, outside of report
					labels.clear
					p_labels.clear
					leaves.clear

				end
			end

		end # m
	end # n
end # k

