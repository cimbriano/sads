require 'sads'
s = Sads.new(0,0,0,true)
f = File.open('./misc/params_bigger_steps.txt', 'w')


f.write("k\t\t\t\tn\t\t\t\tq\t\t\t\t\tL/R dim\t\t\tEstimated Size of L or R\n")

(100..10000).step(1000) do |k|
	(1000..10000000).step(1000000) do |n|
		q = s.calculate_q(k, n)
		l_rows = k
		l_cols = s.calculate_mu(k, q) / 2
		l_num_elements = l_rows * l_cols

		# Assuming 4 bytes per integer
		# size_per_element = 4.0

		# Each element in L can be a number up to q,
		# 		which require the following number of bytes
		size_per_element = Math.log2(q).ceil / 8.0

		# 1048576 bytes per megabyte
		l_data_size = size_per_element * l_num_elements / 1048576

		f.write("#{k}\t\t#{n}\t\t#{q}\t\t#{l_rows} x #{l_cols}\t\t#{'%.0f' % l_data_size}MB\n")
	end
end

f.close