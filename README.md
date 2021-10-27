# Bayesian Network (Coursework done in Plymouth University)

## Introduction

The data used in this coursework are discussed in detail in Højsgaard and Thiesson (1995) and are relevant to coronary artery disease. The following variables are available in the file **Coronary_artery_disease_data_full_names.csv**, with the order being taken from the file. The clinical diagnosis in Coronary_artery_disease on the state of the disease is made on the basis of coronary arteriography. We want to understand the diagnoses in this variable better.

## Variables

Each variable belongs to a ‘block of variables’, as indicated in the table below.

![image info](table-variables.png)

The variable High_heart_rate_or_age is a composite variable and describes whether the heart frequency plus the age of the patient exceed 180; it is better to be No on this variable than Yes. Because High_heart_rate_or_age contains age information, it is taken to be a background variable.
‘Hypertrophy’ is sometimes spelt ‘Hypertrophi’ and is related to increased muscle size.
There are results on the clinical ECG-examinations, that is, information on Q-wave and T -wave presence. In addition, the variables Q_confidence and T_confidence indicate how much confidence to have in the Q-wave and T -wave results. 

## Tasks

### Use of the function hc to learn the structure of a Bayesian Network from the data, by optimising the Bayesian Information Criterion score.

![](CAD_igraph.png)

*Fig. 1: Optimised Bayesian network from raw data provided obtainead using the hill-climbing algorithm in R. Blocks for their respective factors are illustrated with the vertex colours. Lighter colours represent higher blocks and darker colours represent lower blocks.*

Bayesian Information Criterion score: -1668.097

The hill climbing optimistion algorithm starts with an arbitrary solution of the task and by making step by step changes, attempts to find a better solution. The algorithm accepts only the changes which improve the score. The process continues until no more changes can be made to improve it, depends on a problem either maximize or minimize. In our case, hill-climbing starts from the empty graph of the CAD_data data frame and follows the graph from vertex to vertex trying to maximise the score by adding, removing, or reversing the arcs between the vertices. So, only the arcs which improve the score the most are accepted. This process forms the optimal Bayesian network.

### The optimized network computed by **hc** function is ‘implausible’.

The optimised network is implausible as some arcs do not represent realistic relationships between the different factors. For example, the development of habitual smoking or the sex of an individual cannot be affected or influenced by coronary artery disease.
Following the medical doctor’s comments, a better graph was produced showing the ordering of the blocks for their respective variables from the given table. We can see clearly that the arcs are in the direction from the vertices with the lower to higher ordering of blocks. Thus, addressing the discrepancies from the previous graph in Fig. 1 (i.e. sex and smoking influence).

Different colours of the vertices indicate their respective block groups. Colouring was used for visual aid. Darker colours are used to represent blocks with lower ordering while lighter colours represent blocks with higher ordering. This is useful as we can see easily which parameters (vertices) may trigger development of the coronary artery disease and then which types of illnesses are developed in people who already suffer from that disease. It also provides an easy visual check if our network agrees with the imposed blacklist. Lastly, the score for the new network has decreased from -1668.097 to -1677.832, and hence we have a less optimal solution, but better given the additional constraints.

### Introduction of lists of edges that should be included and should not be included.

