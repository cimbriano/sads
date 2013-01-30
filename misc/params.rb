require 'prover'
p = Prover.new(0,0,0,true)
f = File.open('./misc/params_bigger_steps.txt', 'w')


f.write("k\t\tn\t\tq\t\tlog_q\t\tbytes_per_entry\t\tL/R dim\t\t\tEstimated Size of L or R\n")

[100_000].each do |n|

	(1000..10000000).step(1000) do |k|
		q = p.calculate_q(k, n)
		log_q = Math.log2(q).ceil
		l_rows = k
		l_cols = p.calculate_mu(k, q) / 2
		l_num_elements = l_rows * l_cols

		# Assuming 4 bytes per integer
		# size_per_element = 4.0

		# Each element in L can be a number up to q,
		# 		which require the following number of bytes
		bytes_per_entry = (log_q / 8.0).ceil

		# 1048576 bytes per megabyte
		l_data_size = bytes_per_entry * l_num_elements / 1048576
		tabs = "\t" *  ((10 - Math.log10(n)) / 2)

		# line = [k, n, q, log_q, bytes_per_entry, "#{l_rows} x #{l_cols}", "#{'%.0f' % l_data_size}MB"].join(tabs)

		line = [k, n, "#{l_rows} x #{l_cols}", "#{'%.0f' % l_data_size}MB"].join('&')
		f.puts line + '\\\\'

		# f.write("#{k}\t#{n}\t#{q}\t#{l_rows} x #{l_cols}\t#{log_q}\t#{'%.0f' % l_data_size}MB\n")

	end
end

f.close