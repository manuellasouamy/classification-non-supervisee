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

#Classification ascendente hiérarchique
classif = agnes(decath_num_scaled,method="ward")
summary(classif)

#Représentation du dendrogramme
plot(classif,xlab="Individu",ylab="Hauteur", main="Dendrogramme de Decathlon")

#Conversion de la CAH en hclust
classif2 <- as.hclust(classif)

#Découpage visuel possible 
plot(classif2,xlab="Individu",ylab="Hauteur", main="Dendrogramme de Decathlon")
rect.hclust(classif2, k = 3, border = "red")
rect.hclust(classif2, k = 5,border="blue")

#Hauteur des fusions
classif2$height

#Saut d'inertie
plot(rev(classif2$height), type = "h",xlab = "Nombre de classes",ylab = "Hauteur de fusion",main = "Saut d'inertie (CAH) ")

#Méthode des silhouettes
sil_width1 <- numeric(10) #Stockage des silhouettes moyennes
for(k in 2:10){
  classes1 <- cutree(classif2, k = k) #Découpe de la cah en k classes
  sil1 <- silhouette(classes1, dist_matrix)  #Silhouette de chaque individu 
  sil_width1[k] <- mean(sil1[, 3]) #Moyenne de la colonne 3 
}
plot(1:10, sil_width1, type = "b",xlab = "Nombre de clusters",ylab = "Largeur moyenne de silhouette",main = "Méthode des silhouettes (CAH)")

#Découpage en 4 classes
classes2 <- cutree(classif2, k = 4)

#Appartenance des individus aux 4 classes
resultat <- data.frame(Classe = classes2)
resultat

#Visualisation des clusters dans CP1 et CP2
fviz_pca_ind(res.pca,col.ind = as.factor(classes2),addEllipses = TRUE,ellipse.type = "convex",legend.title = "Classe",repel = TRUE,title = "Clusters dans le plan ACP")

#Coordonnées moyennes des classes dans CP1 
round(tapply(res.pca$ind$coord[, 1], classes2, mean),3)  
#Coordonnées moyennes des classes dans CP2
round(tapply(res.pca$ind$coord[, 2], classes2, mean),3)  

#Analyse descriptive des classes
aggregate(decath_num, by = list(cluster = classes2), mean)

#Analyse statistique des classes
classes_cah <- cbind(decath_num, Classe = as.factor(classes2))
catdes(classes_cah, num.var = ncol(classes_cah))

#Qualité de représentation 
sil_cah <- silhouette(classes2, dist_matrix)  # Silhouette de chaque individu par classes
mean(sil_cah[,3]) #Silhouette moyenne des individus
tapply(sil_cah[, 3], classes2, mean) # Silhouette moyenne des individus par classes
fviz_silhouette(sil_cah,main = "Qualité de représentation avec Indice de Silhouette (k = 4)") +
labs(x = "Individus (regroupés par classe)", y = "Largeur de silhouette s(i)") +
ylim(-0.13, 0.4)

#Effectif des classes
table(classes2)

#Rapport de corrélation entre CAH et CP1
aov1_cah <- aov(res.pca$ind$coord[, 1] ~ as.factor(classes2)) #Analyse de la variance
ss1_cah  <- summary(aov1_cah)[[1]][, "Sum Sq"]
round(ss1_cah[1] / sum(ss1_cah), 3)  
#Rapport de corrélation entre CAH et CP2
aov2_cah <- aov(res.pca$ind$coord[, 2] ~ as.factor(classes2))
ss2_cah  <- summary(aov2_cah)[[1]][, "Sum Sq"]
round(ss2_cah[1] / sum(ss2_cah), 3)

#CAH avec d'autres critères d'aggrégation
#Single linkage 
classif_single <- agnes(decath_num_scaled, method = "single")
summary(classif_single)
plot(classif_single,main = "Dendrogramme Lien simple (Single Linkage)",xlab = "Individu", ylab = "Hauteur")
rect.hclust(classif_single, k = 4, border = "red")
cl_single       <- cutree(as.hclust(classif_single), k = 4)
sil_single      <- silhouette(cl_single, dist_matrix)
mean(sil_single[, 3])
#Complete linkage 
classif_complete <- agnes(decath_num_scaled, method = "complete")
summary(classif_complete)
plot(classif_complete,main = "Dendrogramme Lien complet (complete Linkage)",xlab = "Individu", ylab = "Hauteur")
rect.hclust(classif_complete, k = 4, border = "blue")
cl_complete      <- cutree(as.hclust(classif_complete), k = 4)
sil_complete     <- silhouette(cl_complete, dist_matrix)
mean(sil_complete[, 3])
#Average linkage 
classif_average <- agnes(decath_num_scaled, method = "average")
summary(classif_average)
plot(classif_average,main = "Dendrogramme Lien moyen (Average Linkage)",xlab = "Individu", ylab = "Hauteur")
rect.hclust(classif_average, k = 4, border = "green")
cl_average      <- cutree(as.hclust(classif_average), k = 4)
sil_average     <- silhouette(cl_average, dist_matrix)
mean(sil_average[, 3])
#Centroïde 
classif_centroid <- hclust(dist_matrix, method = "centroid")
plot(classif_centroid,main = "Dendrogramme Centre de gravité (centroid Linkage)",xlab = "Individu", ylab = "Hauteur")
rect.hclust(classif_centroid, k = 4, border = "purple")
cl_centroid      <- cutree(classif_centroid, k = 4)
sil_centroid     <- silhouette(cl_centroid, dist_matrix)
mean(sil_centroid[, 3])
