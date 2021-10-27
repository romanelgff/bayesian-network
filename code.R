require(dplyr)
require(dbplyr)
#install.packages("igraph")
require(igraph)
#install.packages("bnlearn")
require(bnlearn)

#install.packages("BiocManager") #need this
#BiocManager::install("graph") #need this
require(graph)

#install.packages("viridis") #need this
require(viridis)
#install.packages("gRbase")
#require(gRbase)

#install.packages("gtools")
require(gtools)
require(ggplot2)

# setwd("...")

# Loading data
data <- read.csv("Coronary_artery_disease_data_full_names.csv")

CAD_data <- as.data.frame(data)
str(CAD_data)
head(CAD_data)
names(CAD_data)
#################################################

# Task 1
# Hill-climbing in this case starts from the empty graph of the CAD_data dataframe,
# and add, remode, reverse all the edges one at a time in order to keep the ones that 
# increase the score the most.
CAD_data.opt <- hc(CAD_data)
#modelstring(CAD_data.opt)
bnlearn::score(CAD_data.opt, data = CAD_data)

# converting to igraph object
CAD_igraph <- igraph.from.graphNEL(as.graphNEL(CAD_data.opt))

# assigning the block attributes
# block value
bloc <- rep(0, gorder(CAD_igraph))
bloc[c(1, 8, 10, 11, 12)] = "Background_variable"
bloc[c(2, 3, 9, 13)] = "Disease_manifestation"
bloc[c(4:7)] = "ECG"
bloc[14] = "Clinical_diagnosis"

# block colour
bloc_col <- rep(0, gorder(CAD_igraph))
bloc_col[c(1, 8, 10, 11, 12)] =  plasma(8)[5]  # Lowest 1
bloc_col[14] =                   plasma(8)[6]  # 2
bloc_col[c(2, 3, 9, 13)] =       plasma(8)[7]  # 3
bloc_col[c(4:7)] =               plasma(8)[8]  # Highest 4

# block rank
bloc_rank <- rep(0, ncol(CAD_data))
bloc_rank[c(1, 8, 10, 11, 12)] = 1
bloc_rank[14] =  2
bloc_rank[c(2, 3, 9, 13)] =  3
bloc_rank[c(4:7)] =  4


# Assigning vertex attributes
V(CAD_igraph)$color <- bloc_col
V(CAD_igraph)$block <- bloc
#vertex.attributes(CAD_igraph)
plot(CAD_igraph)

bn.fit(CAD_data.opt, data = CAD_data)

##############################################################################################

# Task 2
# setting blocks
for(i in 1:ncol(CAD_data)){
  attr(CAD_data[,i], "block") <- bloc[i]
  attr(CAD_data[,i], "rank") <- bloc_rank[i]
}
attributes(CAD_data$Coronary_artery_disease)

# list of permutations
CADedge_name <- permutations(ncol(CAD_data), 2, v = colnames(CAD_data), set = FALSE)
CADedge <- permutations(ncol(CAD_data), 2, set = FALSE)

# function to remove the non-required edges from the blacklist dataframe
edgetorank <- function(df, dfname){ # use CADedge1
  # assigning the rank to the rankdf
  rankdf <- df
  for(i in 1:nrow(df)){
    for(j in 1:2){
      rankdf[i,j] <- bloc_rank[rankdf[i,j]]
    }
  }
  #return(rankdf)
  # removal
  keep <- rep(0, nrow(df))
  for (k in 1:nrow(df)){
    if(rankdf[k,1] <= rankdf[k,2]){
      keep[k] <- k
    }
  }
  keep <- keep[keep != 0]
  #return(keep)
  # reassigning
  #blkn <- rankdf[keep,]
  blk <- as.data.frame(dfname[-keep,])
  #return(blkn)
  return(blk)
}

blk <- edgetorank(CADedge, CADedge_name)
blk

CAD_2 <- hc(CAD_data, blacklist = blk)
CAD_2igraph <- igraph.from.graphNEL(as.graphNEL(CAD_2))


V(CAD_2igraph)$color <- bloc_col
V(CAD_2igraph)$block <- bloc
plot(CAD_2igraph)

bn.fit(CAD_2, data = CAD_data)
bnlearn::score(CAD_2, CAD_data)

###############################################################################
# Task 3
in_names_df <- matrix(c("Sex", "Smoker",
                        "Hereditary_predispositions", "Coronary_artery_disease",
                        "Coronary_artery_disease", "Previous_myocardial_infarction",
                        "Coronary_artery_disease", "Angina_pectoria",
                        "Q_confidence", "Q_wave",
                        "T_confidence", "T_wave",
                        "Smoker", "Hypercholesterolaemia"), ncol = 2, byrow = TRUE)#,
                      #dimnames = list(NULL,c("from", "to")))

out_names_df <- matrix(c("High_heart_rate_or_age", "Hypercholesterolaemia",
                          "Hypercholesterolaemia", "High_heart_rate_or_age",
                          "Angina_pectoria", "Previous_myocardial_infarction",
                          "Previous_myocardial_infarction", "Angina_pectoria",
                          "Hypertrophy", "Coronary_artery_disease",
                          "Coronary_artery_disease", "Hypertrophy",
                          "Hypercholesterolaemia", "Angina_pectoria",
                          "Angina_pectoria", "Hypercholesterolaemia"),ncol = 2, byrow = TRUE) #,
                       #dimnames = list(NULL,c("from", "to")))
bl <- rbind(blk, out_names_df)
bl

# optimising new CAD
CAD_3 <- hc(CAD_data, blacklist = bl, whitelist = in_names_df)
CAD_3igraph <- igraph.from.graphNEL(as.graphNEL(CAD_3))

V(CAD_3igraph)$color <- bloc_col
V(CAD_3igraph)$block <- bloc
plot(CAD_3igraph)

bn.fit(CAD_3, CAD_data)
bnlearn::score(CAD_3, CAD_data)
arcs(CAD_3)
arcs(CAD_2)
arcs(bn.fit(CAD_data.opt, data = CAD_data))

#########################################################################################
# Task 4
m <- bn.fit(CAD_3, CAD_data, method ="mle")
m$Coronary_artery_disease

# calculate by hand
t <- table(CAD_data[, c(14, 10, 12)])
t
prop.table(t, c(3, 2))

# results agree

#########################################################################################
# Task 5
bn.fit.barchart(m$Coronary_artery_disease,
                main = "Conditional Probabilities for Node Coronary_artery_disease",
                xlab = "Pr(Coronary_artery_disease | Hypercholesterolaemia, Hereditary_predispositions",
                ylab = "Coronary_artery_disease")
bn.fit.barchart(m$Q_wave,
                main = "Conditional Probabilities for Node Q_wave",
                xlab = "Pr(Q_wave | Q_confidence, Coronary_artery_disease",
                ylab = "Q_wave")
m$Q_wave

################################################################################
# Task 6
ci.test("Smoker","Hypercholesterolaemia",
        test = "mi",
        data = CAD_data)
# keep arc

ci.test("Q_confidence","Q_wave",
        test = "mi",
        data = CAD_data)
# keep arc

ci.test("Coronary_artery_disease","T_confidence",
        test = "mi",
        data = CAD_data)
# keep arc

###############################################################################
# Task 7
m1 <- bn.fit(CAD_data.opt, CAD_data, method ="mle")

# logic sampling
cpquery(m1, (Coronary_artery_disease == "Yes"),
          (Sex == "Female") &
          (Smoker == "No") &
          (High_heart_rate_or_age == "Yes") &
          (Angina_pectoria == "Atypical") &
          (T_wave == "Yes") &
          (Q_wave == "No"), n = 1000000, method ="ls")

lsm_df <- replicate(100, 
                     cpquery(m1, (Coronary_artery_disease == "Yes"),
                                (Sex == "Female") &
                                (Smoker == "No") &
                                (High_heart_rate_or_age == "Yes") &
                                (Angina_pectoria == "Atypical") &
                                (T_wave == "Yes") &
                                (Q_wave == "No"), n = 1000000, method ="ls"))

lsm_df1 <- as.data.frame(lsm_df)

# likelihood weighting
lwm_df <- replicate(100,
                    cpquery(m1, (Coronary_artery_disease == "Yes"),
                                list(Sex = "Female", Smoker = "No",
                                High_heart_rate_or_age = "Yes",
                                Angina_pectoria = "Atypical",
                                T_wave = "Yes",
                                Q_wave = "No"), n = 1000000, method = "lw"))

lwm_df1 <- as.data.frame(lwm_df)

# plot
ggplot(lsm_df1, aes(x = c(1:100), y = lsm_df, color = "Logic sampling")) +
  geom_line() +
  geom_point(lwm_df1, mapping = aes(y = lwm_df, color = "Likelihood weighting")) +
  labs(x = "n",
       y = "Probability estimate",
       title = "Probability estimates using logic sampling vs likelihood weighting")

###############################################################################
# Task 8 (load task 1 to 3)
head(CAD_data)
CAD8 <- CAD_data[,-c(4:7)]
head(CAD8)
attributes(CAD8$Coronary_artery_disease)

cad8p <- permutations(ncol(CAD8), 2, set = FALSE)

cad8edgename <- permutations(ncol(CAD8), 2, v = colnames(CAD8), set = FALSE)
cad8edgenum <- permutations(ncol(CAD8), 2, set = FALSE)

blk8 <- edgetorank(cad8edgenum, cad8edgename)

in_names_df8 <- matrix(c("Sex", "Smoker",
                        "Hereditary_predispositions", "Coronary_artery_disease",
                        "Coronary_artery_disease", "Previous_myocardial_infarction",
                        "Coronary_artery_disease", "Angina_pectoria",
                        "Smoker", "Hypercholesterolaemia"), ncol = 2, byrow = TRUE)
in_names_df8

out_names_df8 <- matrix(c("High_heart_rate_or_age", "Hypercholesterolaemia",
                         "Hypercholesterolaemia", "High_heart_rate_or_age",
                         "Angina_pectoria", "Previous_myocardial_infarction",
                         "Previous_myocardial_infarction", "Angina_pectoria",
                         "Hypertrophy", "Coronary_artery_disease",
                         "Coronary_artery_disease", "Hypertrophy",
                         "Hypercholesterolaemia", "Angina_pectoria",
                         "Angina_pectoria", "Hypercholesterolaemia"),ncol = 2, byrow = TRUE)

blk8
out_names_df8

bl8 <- rbind(blk8, out_names_df8)

CAD_8 <- hc(CAD8, blacklist = bl8, whitelist = in_names_df8)
CAD_8igraph <- igraph.from.graphNEL(as.graphNEL(CAD_8))

bloc_col8 <- bloc_col[-c(4:7)]
V(CAD_8igraph)$color <- bloc_col8
V(CAD_8igraph)$block <- bloc
plot(CAD_8igraph)

bn.fit(CAD_3, CAD_data)
bnlearn::score(CAD_3, CAD_data)

# likelihood weighting
cpquery(bn.fit(CAD_8, CAD8, method = "mle"), (Coronary_artery_disease == "Yes"),
        list(Sex = "Female", Smoker = "No",
             Previous_myocardial_infarction = "Definite",
             Angina_pectoria = "Atypical"), n = 1000000, method = "lw")

cpquery(bn.fit(CAD_3, CAD_data, method = "mle"), (Coronary_artery_disease == "Yes"),
        list(Sex = "Female", Smoker = "No",
             Previous_myocardial_infarction = "Definite",
             Angina_pectoria = "Atypical",             
             T_wave = "Yes",
             Q_wave = "Yes"), n = 1000000, method = "lw")
cpquery(bn.fit(CAD_3, CAD_data, method = "mle"), (Coronary_artery_disease == "Yes"),
        list(Sex = "Female", Smoker = "No",
             Previous_myocardial_infarction = "Definite",
             Angina_pectoria = "Atypical",             
             T_wave = "Yes",
             Q_wave = "No"), n = 1000000, method = "lw")
cpquery(bn.fit(CAD_3, CAD_data, method = "mle"), (Coronary_artery_disease == "Yes"),
        list(Sex = "Female", Smoker = "No",
             Previous_myocardial_infarction = "Definite",
             Angina_pectoria = "Atypical",             
             T_wave = "No",
             Q_wave = "Yes"), n = 1000000, method = "lw")
cpquery(bn.fit(CAD_3, CAD_data, method = "mle"), (Coronary_artery_disease == "Yes"),
        list(Sex = "Female", Smoker = "No",
             Previous_myocardial_infarction = "Definite",
             Angina_pectoria = "Atypical",             
             T_wave = "No",
             Q_wave = "No"), n = 1000000, method = "lw")




