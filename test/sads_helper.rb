
def LR_matrix(k, m, q)
	Matrix.build(k, m) { rand q}
end

def column_vector(size)
	Matrix.column_vector( (0...size).to_a )
end