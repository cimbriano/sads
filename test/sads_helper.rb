
def LR_matrix(k, m, q)
	Matrix.build(k, m) { rand q}
end

def node_label(m)
	Matrix.column_vector( (0...m).to_a )
end