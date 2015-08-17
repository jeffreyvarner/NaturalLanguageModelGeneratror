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
# Kinetics.jl
# Encodes the metabolic and gene expression kinetics.
# Called by Balances.jl
#
# Generated on: 8/17/2015
# Generated by: jeffreyvarner
# ------------------------------------------------------------------------------------- #
function Kinetics(t,x,DF)

	# Initialize empty *_rate_vectors - 
	gene_expression_rate_vector = Float64[]
	basal_gene_expression_rate_vector = Float64[]
	metabolic_rate_vector = Float64[]
	translation_rate_vector = Float64[]
	mRNA_degradation_rate_vector = Float64[]
	protein_degradation_rate_vector = Float64[]
	system_transfer_rate_vector = zeros(Float64,length(x));

	# Alias state vector - 
	G_P_1	=	x[1]
	G_P_2	=	x[2]
	G_P_3	=	x[3]
	MRNA_P_1	=	x[4]
	MRNA_P_2	=	x[5]
	MRNA_P_3	=	x[6]
	P_1	=	x[7]
	P_2	=	x[8]
	P_3	=	x[9]
	M_1	=	x[10]

	# Get the parameter vectors from DF - 
	gene_expression_parameter_vector = DF["GENE_EXPRESSION_KINETIC_PARAMETER_VECTOR"]
	metabolic_kinetic_parameter_vector = DF["METABOLIC_KINETIC_PARAMETER_VECTOR"]
	system_transfer_paramter_array = DF["SYSTEM_TRANSFER_PARAMETER_ARRAY"]

	# Regulated gene expression rate vector - 
	fill!(gene_expression_rate_vector,0.0)
	push!(gene_expression_rate_vector,gene_expression_parameter_vector[1]*G_P_1)
	push!(gene_expression_rate_vector,gene_expression_parameter_vector[4]*G_P_2)
	push!(gene_expression_rate_vector,gene_expression_parameter_vector[7]*G_P_3)

	# Basal gene expression rate vector - 
	fill!(basal_gene_expression_rate_vector,0.0)
	push!(basal_gene_expression_rate_vector,gene_expression_parameter_vector[2]);
	push!(basal_gene_expression_rate_vector,gene_expression_parameter_vector[5]);
	push!(basal_gene_expression_rate_vector,gene_expression_parameter_vector[8]);

	# Define the translation rate vector - 
	fill!(translation_rate_vector,0.0)
	push!(translation_rate_vector,gene_expression_parameter_vector[10]*MRNA_P_1)
	push!(translation_rate_vector,gene_expression_parameter_vector[12]*MRNA_P_2)
	push!(translation_rate_vector,gene_expression_parameter_vector[14]*MRNA_P_3)

	# Define the mRNA degradation rate vector - 
	fill!(mRNA_degradation_rate_vector,0.0)
	push!(mRNA_degradation_rate_vector,gene_expression_parameter_vector[3]*MRNA_P_1)
	push!(mRNA_degradation_rate_vector,gene_expression_parameter_vector[6]*MRNA_P_2)
	push!(mRNA_degradation_rate_vector,gene_expression_parameter_vector[9]*MRNA_P_3)

	# Define the protein degradation rate vector - 
	fill!(protein_degradation_rate_vector,0.0)
	push!(protein_degradation_rate_vector,gene_expression_parameter_vector[11]*P_1)
	push!(protein_degradation_rate_vector,gene_expression_parameter_vector[13]*P_2)
	push!(protein_degradation_rate_vector,gene_expression_parameter_vector[15]*P_3)

	# Define the metabolic rate vector - 
	# Alias the metabolic kinetic parameter vector - 

	# Define the system transfer rate vector - 
	system_transfer_rate_vector[1] = system_transfer_paramter_array[1,1] - (system_transfer_paramter_array[1,2] + system_transfer_paramter_array[1,3])*G_P_1;
	system_transfer_rate_vector[2] = system_transfer_paramter_array[2,1] - (system_transfer_paramter_array[2,2] + system_transfer_paramter_array[2,3])*G_P_2;
	system_transfer_rate_vector[3] = system_transfer_paramter_array[3,1] - (system_transfer_paramter_array[3,2] + system_transfer_paramter_array[3,3])*G_P_3;
	system_transfer_rate_vector[4] = system_transfer_paramter_array[4,1] - (system_transfer_paramter_array[4,2] + system_transfer_paramter_array[4,3])*MRNA_P_1;
	system_transfer_rate_vector[5] = system_transfer_paramter_array[5,1] - (system_transfer_paramter_array[5,2] + system_transfer_paramter_array[5,3])*MRNA_P_2;
	system_transfer_rate_vector[6] = system_transfer_paramter_array[6,1] - (system_transfer_paramter_array[6,2] + system_transfer_paramter_array[6,3])*MRNA_P_3;
	system_transfer_rate_vector[7] = system_transfer_paramter_array[7,1] - (system_transfer_paramter_array[7,2] + system_transfer_paramter_array[7,3])*P_1;
	system_transfer_rate_vector[8] = system_transfer_paramter_array[8,1] - (system_transfer_paramter_array[8,2] + system_transfer_paramter_array[8,3])*P_2;
	system_transfer_rate_vector[9] = system_transfer_paramter_array[9,1] - (system_transfer_paramter_array[9,2] + system_transfer_paramter_array[9,3])*P_3;
	system_transfer_rate_vector[10] = system_transfer_paramter_array[10,1] - (system_transfer_paramter_array[10,2] + system_transfer_paramter_array[10,3])*M_1;

	# Return the rate vectors to the caller in a dictionary - 
	# - DO NOT EDIT BELOW THIS LINE ------------------------------ 
	kinetics_dictionary = Dict()
	kinetics_dictionary["gene_expression_rate_vector"] = gene_expression_rate_vector;
	kinetics_dictionary["basal_gene_expression_rate_vector"] = basal_gene_expression_rate_vector;
	kinetics_dictionary["translation_rate_vector"] = translation_rate_vector;
	kinetics_dictionary["mRNA_degradation_rate_vector"] = mRNA_degradation_rate_vector;
	kinetics_dictionary["protein_degradation_rate_vector"] = protein_degradation_rate_vector;
	kinetics_dictionary["metabolic_rate_vector"] = metabolic_rate_vector;
	kinetics_dictionary["system_transfer_rate_vector"] = system_transfer_rate_vector;
	# - DO NOT EDIT ABOVE THIS LINE ------------------------------ 
	return kinetics_dictionary
end