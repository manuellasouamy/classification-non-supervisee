if(!require(factoextra)) install.packages("factoextra")
if(!require(FactoMineR)) install.packages("FactoMineR")


#Chargement des données
load("decath.Rda")

#Résumé de décathlon 
str(decathlon)
summary(decathlon)

#Sélection des variables quantitatives
data_num <- decathlon[, sapply(decathlon, is.numeric)]

#Suppréssion des variables à double sens
decath_num <- subset(data_num, select = -c(Classement,Points))
decath_num

#Centrage et normalisation
decath_num_scaled <- scale(decath_num)

#Vérification de la moyenne ≈ 0 et de l'écart ≈ 1
colMeans(decath_num_scaled)   
apply(decath_num_scaled, 2, sd)

#Matrice des corrélations des variables
round(cor(decath_num),2)

#Calcul de l'ACP
res.pca <- PCA(decath_num, scale.unit = TRUE, graph = TRUE)

#valeurs propres et variance 
round(res.pca$eig,2)

#Critère de Kaiser 
res.pca$eig[, 1] > 1
#Indice des composantes retenues
which(res.pca$eig[, 1] > 1)
#Nombre de composantes retenues 
sum(res.pca$eig[, 1] > 1)
    
#Scree plot 
plot(res.pca$eig[, 1],type = "b",xlab = "Composantes principales",ylab = "Valeurs propres",main = "Scree plot")
#Scree plot avec variance expliquée
fviz_eig(res.pca,addlabels = TRUE,ylim = c(0, 35),main = "Scree plot avec variance expliquée",xlab = "Composantes principales",ylab = "Pourcentage de variance expliquée (%)")

#Tableau des contributions des variables à CP1 et CP2
round(res.pca$var$contrib[, 1:2], 2)
#Contribution des variables à CP1
fviz_contrib(res.pca, choice = "var", axes = 1, title = "Contribution des variables à CP1")
#Contribution des variables à CP2
fviz_contrib(res.pca, choice = "var", axes = 2, title = "Contribution des variables à CP2")
#Contribution des variables à CP1 et CP2
fviz_contrib(res.pca,title="Contribution des variables à CP1 et CP2", choice = "var", axes = c(1,2))

#Tableau des contributions des individus aux CP 1 et 2
round(res.pca$ind$contrib[,1:2],2) 
#Contribution à CP1
fviz_contrib(res.pca, choice = "ind", axes = 1, top = 15, title = "Contribution des athlètes à CP1")
#Contribution à CP2
fviz_contrib(res.pca, choice = "ind", axes = 2, top = 15, title = "Contribution des athlètes à CP2")
#Contribution à CP1 et CP2
fviz_contrib(res.pca, title="Contribution des athlètes à CP1 et CP2", choice = "ind", axes = c(1,2), top = 15)
#Top 15 des individus contribuant le plus à CP1 et CP2
w <- res.pca$eig[1:2,1] / sum(res.pca$eig[1:2,1])
contrib_pond <- as.numeric(res.pca$ind$contrib[,1:2] %*% w)
round(res.pca$ind$contrib[order(contrib_pond, decreasing = TRUE), 1:2][1:15, ], 2)

#Qualité de représentation des individus sur CP1 et CP2
round(res.pca$ind$cos2[,1:2],2) 
fviz_pca_ind(res.pca,geom = c("point", "text"),col.ind = "cos2",gradient.cols = c("lightgray", "blue", "red"),repel = TRUE,title = "Qualité de représentation (cos²)")
#Qualité de représentation moyenne dans le plan ACP
mean(res.pca$ind$cos2[, 1] + res.pca$ind$cos2[, 2])
#Top 10 des individus les mieux représentés  
cos2 <- round(res.pca$ind$cos2[, 1:2], 2)
head(cos2[order(cos2[,1] + cos2[,2], decreasing = TRUE), ], 10)

# Construire un data frame avec les 10 variables + Competition
data_pour_pca <- cbind(decath_num, Competition = decathlon$Competition)
#Répartition des athlètes
fviz_pca_ind(res.pca, geom.ind = c("point", "text"),habillage = data_pour_pca$Competition,palette = "jco",addEllipses = TRUE,legend.title = "Compétition",repel = TRUE,title = "Répartition des athlètes en fonction de la compétition")

#Corrélations des variables avec CP1 et CP2
round(res.pca$var$cor[, 1:2], 2)
#Coordonnées des individus sur CP1 et CP2
round(res.pca$ind$coord[, 1:2], 2)
#Tableau des coordonnées des individus sur les 3 premières composante
data_acp <- res.pca$ind$coord[, 1:3]
data_acp

