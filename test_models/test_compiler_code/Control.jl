# ------------------------------------------------------------------------------------- #
# Copyright (c) 2015 Varnerlab,
# School of Chemical and Biomolecular Engineering,
# Cornell University, Ithaca NY 14853 USA.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# Control.jl
# Calculates the metabolic and gene expression control vector. Called by Balances.jl.
#
# Generated on: 7/19/2015
# Generated by: jeffreyvarner
# ------------------------------------------------------------------------------------- #
function Control(t,x,rate_vector,metabolic_rate_vector,DF)

	# Initialize control_vector - 
	control_vector_gene_expression = Float64[];
	control_vector_metabolism = Float64[];

	# Get the parameter_vector - 
	g = DF["GENE_EXPRESSION_CONTROL_PARAMETER_VECTOR"];
	m = DF["METABOLIC_CONTROL_PARAMETER_VECTOR"];

	# Alias the state vector - 
	G_P_1	=	x[1];
	G_P_3	=	x[2];
	G_P_2	=	x[3];
	G_P_4	=	x[4];
	MRNA_P_1	=	x[5];
	MRNA_P_3	=	x[6];
	MRNA_P_2	=	x[7];
	MRNA_P_4	=	x[8];
	P_1	=	x[9];
	P_3	=	x[10];
	P_2	=	x[11];
	P_4	=	x[12];
	M_1	=	x[13];
	M_2	=	x[14];
	M_3	=	x[15];

	# Formulate the gene expression control vector - 
	# Control structure for P_3
	f_vector = Float64[]
	push!(f_vector,1.0 - (g[1]*(P_2)^g[2])/(1 + g[1]*(P_2)^g[2]));
	push!(control_vector_gene_expression,mean(f_vector));

	# Control structure for P_2
	f_vector = Float64[]
	push!(f_vector,(g[3]*(P_1)^g[4])/(1 + g[3]*(P_1)^g[4]));
	push!(f_vector,(g[5]*(P_2)^g[6])/(1 + g[5]*(P_2)^g[6]));
	push!(f_vector,(g[7]*(P3)^g[8])/(1 + g[7]*(P3)^g[8]));
	push!(control_vector_gene_expression,mean(f_vector));

	# Control structure for P_4
	f_vector = Float64[]
	push!(f_vector,(g[9]*(P_1)^g[10])/(1 + g[9]*(P_1)^g[10]));
	push!(f_vector,(g[11]*(P_2)^g[12])/(1 + g[11]*(P_2)^g[12]));
	push!(f_vector,(g[13]*(P3)^g[14])/(1 + g[13]*(P3)^g[14]));
	push!(control_vector_gene_expression,mean(f_vector));

	# Return the gene expression and metabolic control vectors - 
	return (control_vector_gene_expression, control_vector_metabolism)
end