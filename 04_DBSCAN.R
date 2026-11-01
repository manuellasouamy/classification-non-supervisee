if(!require(factoextra)) install.packages("factoextra")
if(!require(FactoMineR)) install.packages("FactoMineR")
if(!require(cluster)) install.packages("cluster")
if(!require(dbscan)) install.packages("dbscan")

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


#ACP pour la projection des clusters
res.pca <- PCA(decath_num, scale.unit = TRUE, graph = FALSE)

# 1. K-distance plot sur les dix variables standardisées (minPts = 4)
kNNdistplot(decath_num_scaled, k = 4)
abline(h = 2.5, lty = 2, col = "red")
title("k-distance plot (k = 4) — données standardisées")

# 2. Test sur les dix variables standardisées
for (eps_val in c(2.5, 3.0, 3.5, 4.0)) {
  res <- dbscan(decath_num_scaled, eps = eps_val, minPts = 4)
  cat("eps =", eps_val,
      "| clusters :", max(res$cluster),
      "| bruit :", sum(res$cluster == 0), "\n")
}
# → 1 seul cluster dans tous les cas : DBSCAN inadapté en 10D

# 3. Passage sur les composantes principales 
coord<- res.pca$ind$coord[, 1:2]

# K-distance plot sur CP1 et CP2
kNNdistplot(coord, k = 3)
abline(h = 1.5, lty = 2, col = "red")
title("k-distance plot (k = 3) — espace CP1/CP2")

# Test de paramètres sur CP1/CP2
for (eps_val in c(1.5, 2.0, 2.5)) {
  res <- dbscan(coord, eps = eps_val, minPts = 3)
  cat("eps =", eps_val, "| minPts = 3",
      "| clusters :", max(res$cluster),
      "| bruit :", sum(res$cluster == 0), "\n")
}

# 4. Modèle retenu : eps = 1.5, MinPts = 3
res_dbscan <- dbscan(coord, eps = 1.5, minPts = 3)
res_dbscan

#Composition des clusters
for (k in 0:3) {
  cat("\n--- Cluster", k,
      ifelse(k == 0, "(bruit)", ""), "---\n")
  print(rownames(decath_num_scaled)[res_dbscan$cluster == k])
}

# 5. Visualisation 
# Créer un data frame complet avec labels et clusters
df_plot <- data.frame(coord,
                      cluster = as.factor(res_dbscan$cluster),
                      label   = rownames(coord))

ggplot(df_plot, aes(x = Dim.1, y = Dim.2, 
                    color = cluster, label = label)) +
  geom_point(size = 2) +
  geom_text(size = 2.5, vjust = -0.6) +
  scale_color_manual(values = c("0" = "black", "1" = "red", 
                                "2" = "blue", "3" = "green3"),
                     labels = c("0" = "Bruit", "1" = "Cluster 1",
                                "2" = "Cluster 2", "3" = "Cluster 3")) +
  theme_minimal() +
  labs(title = "DBSCAN : clusters dans CP1/CP2 (eps=1.5, minPts=3)",
       color = "Cluster")

# 6. Profils descriptifs par cluster 
clusters_dbscan <- res_dbscan$cluster
clusters_dbscan
# Moyennes par cluster (hors bruit)
aggregate(decath_num[clusters_dbscan != 0, ],
          by = list(Cluster = clusters_dbscan[clusters_dbscan != 0]),
          FUN = mean)
# Caractérisation statistique avec catdes
data_catdes <- data.frame(decath_num,cluster = as.factor(clusters_dbscan))
catdes(data_catdes, num.var = ncol(data_catdes), proba = 0.05)

# 7. Silhouette (hors bruit)
idx <- res_dbscan$cluster != 0
sil <- silhouette(res_dbscan$cluster[idx], dist(coord[idx, ]))
mean(sil[, 3])
summary(sil)

fviz_silhouette(sil) +labs(title = "DBSCAN : silhouette par cluster")


# 8. Coordonnées moyennes par cluster DBSCAN dans le plan ACP
aggregate(coord, by = list(Cluster = res_dbscan$cluster), FUN = mean)

# 9. Rapport de corrélation η² avec CP1 et CP2
cluster_factor <- as.factor(res_dbscan$cluster)

# η² CP1
aov_cp1 <- summary(aov(coord[,1] ~ cluster_factor))[[1]]
eta2_cp1 <- aov_cp1["Sum Sq"][1,] / sum(aov_cp1["Sum Sq"])

# η² CP2
aov_cp2 <- summary(aov(coord[,2] ~ cluster_factor))[[1]]
eta2_cp2 <- aov_cp2["Sum Sq"][1,] / sum(aov_cp2["Sum Sq"])

cat("η² CP1 :", round(eta2_cp1, 3), "\n")
cat("η² CP2 :", round(eta2_cp2, 3), "\n")


