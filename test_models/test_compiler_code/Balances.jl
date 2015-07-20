# Include statements - 
include("Kinetics.jl")
include("Control.jl")

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
# Balances.jl
# Encodes the material balance equations for the metabolic model.
# Called by SolveBalanceEquations.jl
#
# Generated on: 7/20/2015
# Generated by: jeffreyvarner
# ------------------------------------------------------------------------------------- #
function Balances(t,x,dxdt_vector,DF)

	# Define the rate_vector - 
	kinetics_dictionary = Kinetics(t,x,DF);
	gene_expression_rate_vector = kinetics_dictionary["gene_expression_rate_vector"];
	basal_gene_expression_rate_vector = kinetics_dictionary["basal_gene_expression_rate_vector"];
	translation_rate_vector = kinetics_dictionary["translation_rate_vector"];
	metabolic_rate_vector = kinetics_dictionary["metabolic_rate_vector"];
	mRNA_degradation_rate_vector = kinetics_dictionary["mRNA_degradation_rate_vector"];
	protein_degradation_rate_vector = kinetics_dictionary["protein_degradation_rate_vector"];
	system_transfer_rate_vector = kinetics_dictionary["system_transfer_rate_vector"];

	# Define the control_vector - 
	(gene_expression_control_vector, metabolic_control_vector) = Control(t,x,gene_expression_rate_vector,metabolic_rate_vector,DF);

	# Correct the gene expression rate vector - 
	gene_expression_rate_vector = gene_expression_rate_vector.*gene_expression_control_vector;

	# Correct the metabolic rate vector - 
	metabolic_rate_vector = metabolic_rate_vector.*metabolic_control_vector;

	# Define the dxdt_vector - 
	# Gene balances - 
	dxdt_vector[1] = system_transfer_rate_vector[1];	#	1	G_P_1
	dxdt_vector[2] = system_transfer_rate_vector[2];	#	2	G_P_3
	dxdt_vector[3] = system_transfer_rate_vector[3];	#	3	G_P_2
	dxdt_vector[4] = system_transfer_rate_vector[4];	#	4	G_P_4

	# mRNA balances - 
	dxdt_vector[5] = system_transfer_rate_vector[5];	#	5	MRNA_P_1
	dxdt_vector[6] = gene_expression_rate_vector[1] - mRNA_degradation_rate_vector[1] + basal_gene_expression_rate_vector[1] + system_transfer_rate_vector[6];	#	6	MRNA_P_3
	dxdt_vector[7] = gene_expression_rate_vector[2] - mRNA_degradation_rate_vector[2] + basal_gene_expression_rate_vector[2] + system_transfer_rate_vector[7];	#	7	MRNA_P_2
	dxdt_vector[8] = gene_expression_rate_vector[3] - mRNA_degradation_rate_vector[3] + basal_gene_expression_rate_vector[3] + system_transfer_rate_vector[8];	#	8	MRNA_P_4

	# Protein balances - 
	dxdt_vector[9] = system_transfer_rate_vector[9];	#	9	P_1
	dxdt_vector[10] = translation_rate_vector[1] - protein_degradation_rate_vector[1] + system_transfer_rate_vector[10];	#	10	P_3
	dxdt_vector[11] = translation_rate_vector[2] - protein_degradation_rate_vector[2] + system_transfer_rate_vector[11];	#	11	P_2
	dxdt_vector[12] = translation_rate_vector[3] - protein_degradation_rate_vector[3] + system_transfer_rate_vector[12];	#	12	P_4
	return dxdt_vector;
end