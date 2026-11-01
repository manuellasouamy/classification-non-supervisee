if(!require(factoextra)) install.packages("factoextra")
if(!require(FactoMineR)) install.packages("FactoMineR")
if(!require(cluster)) install.packages("cluster")

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

#Calcul de la matrice de distances
dist_matrix <- dist(decath_num_scaled, method = "euclidean")

#ACP pour la projection des clusters
res.pca <- PCA(decath_num, scale.unit = TRUE, graph = FALSE)

#Méthode du coude
wss <- numeric(10) # Stockage des valeurs d'inertie intra-classe 
for(k in 1:10){
  set.seed(123) #Valeur initiale
  km_temp <- kmeans(decath_num_scaled, centers = k,nstart = 25, iter.max = 100) #Application de K-means
  wss[k]  <- km_temp$tot.withinss #Extraction de la somme des distances au carré entre chaque individu et le centre de sa classe
}
plot(1:10, wss,type = "b",pch  = 16,xlab = "Nombre de classes",ylab = "Inertie intra-classe (WSS)",main = "Méthode du coude (K-means)")

#Méthode des silhouettes
sil_width2 <- numeric(10)
for(k in 2:10){
  set.seed(123)
  km_temp <- kmeans(decath_num_scaled, centers = k,nstart = 25, iter.max = 100)
  sil2 <- silhouette(km_temp$cluster, dist_matrix)
  sil_width2[k] <- mean(sil2[, 3])
}
plot(1:10, sil_width2,type = "b",pch  = 16,xlab = "Nombre de clusters",ylab = "Largeur moyenne de silhouette",main = "Méthode des silhouettes (K-means)")

#Application du K-means avec le nombre de classes retenu
set.seed(123)
km <- kmeans(decath_num_scaled, centers = 4, nstart = 25, iter.max = 100)

#Appartenance des athlètes aux 4 classes
km$cluster
#Matrice des coordonnées des 4 classes
km$centers
#Inertie intra-classe totale
km$tot.withinss
#Inertie inter-classes
km$betweenss
#Pourcentage de variance expliquée
km$betweenss / km$totss * 100


#Visualisation des clusters dans le plan de l'ACP (res.pca)
fviz_pca_ind(res.pca,col.ind = as.factor(km$cluster),addEllipses = TRUE,ellipse.type = "convex",legend.title = "Classe",repel = TRUE,title= "Clusters dans le plan ACP")

#Coordonnées moyennes des classes dans CP1 
round(tapply(res.pca$ind$coord[, 1], km$cluster, mean),3)  
#Coordonnées moyennes des classes dans CP2
round(tapply(res.pca$ind$coord[, 2], km$cluster, mean),3) 

#Analyse descriptive des classes
aggregate(decath_num, by = list(cluster = km$cluster), mean)

#Analyse statistique des classes
classes_km <- cbind(decath_num, Classe = as.factor(km$cluster))
catdes(classes_km, num.var = ncol(classes_km))

#Qualité de représentation 
sil_km <- silhouette(km$cluster, dist_matrix)
mean(sil_km[, 3])
tapply(sil_km[, 3], km$cluster, mean)
fviz_silhouette(sil_km,main = "Qualité de représentation avec Indice de Silhouette (k = 4)") +
  labs(x = "Individus (regroupés par classe)",y = "Largeur de silhouette s(i)") +
  ylim(-0.12, 0.4)

# Effectif des classes
table(km$cluster)


#Rapport de corrélation entre K-means et CP1
aov1_km <- aov(res.pca$ind$coord[, 1] ~ as.factor(km$cluster))
ss1_km  <- summary(aov1_km)[[1]][, "Sum Sq"]
round(ss1_km[1] / sum(ss1_km), 3)
#Rapport de corrélation entre K-means et CP2
aov2_km <- aov(res.pca$ind$coord[, 2] ~ as.factor(km$cluster))
ss2_km  <- summary(aov2_km)[[1]][, "Sum Sq"]
round(ss2_km[1] / sum(ss2_km), 3)

