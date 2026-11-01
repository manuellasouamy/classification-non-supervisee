library(cluster)

data(USArrests)

# 6 premieres lignes
head(USArrests)

# Résumé statistique
summary(USArrests)


usa_scaled <- scale(USArrests)
delta_usa  <- dist(usa_scaled, method = "euclidean")


# Lien simple

hc_single  <- hclust(delta_usa, method = "single")
g_single   <- cutree(hc_single, k = 3)

plot(hc_single,
     main  = "CAH - Critère du lien simple (Single)",
     xlab  = "",
     sub   = "",
     ylab  = "Hauteur",
     cex   = 0.7,
     hang  = -1)
rect.hclust(hc_single, k = 3,
            border = c("blue", "red", "darkgreen"))

cat("Lien simple — effectifs :", table(g_single), "\n")


#Lien complet

hc_complete <- hclust(delta_usa, method = "complete")
g_complete  <- cutree(hc_complete, k = 3)

plot(hc_complete,
     main  = "CAH - Critère du lien complet (Complete)",
     xlab  = "",
     sub   = "",
     ylab  = "Hauteur",
     cex   = 0.7,
     hang  = -1)
rect.hclust(hc_complete, k = 3,
            border = c("blue", "red", "darkgreen"))

cat("Lien complet — effectifs :", table(g_complete), "\n")


#Lien moyen

hc_average <- hclust(delta_usa, method = "average")
g_average  <- cutree(hc_average, k = 3)

plot(hc_average,
     main  = "CAH - Critère du lien moyen (Average)",
     xlab  = "",
     sub   = "",
     ylab  = "Hauteur",
     cex   = 0.7,
     hang  = -1)
rect.hclust(hc_average, k = 3,
            border = c("blue", "red", "darkgreen"))

cat("Lien moyen — effectifs :", table(g_average), "\n")

#Centroide

hc_centroid <- hclust(delta_usa, method = "centroid")
g_centroid  <- cutree(hc_centroid, k = 3)

plot(hc_centroid,
     main  = "CAH - Méthode du centroïde (Centroid)",
     xlab  = "",
     sub   = "",
     ylab  = "Hauteur",
     cex   = 0.7,
     hang  = -1)
rect.hclust(hc_centroid, k = 3,
            border = c("blue", "red", "darkgreen"))

cat("Centroide — effectifs :", table(g_centroid), "\n")

# Detection des inversions
h   <- hc_centroid$height
inv <- which(diff(h) < 0)
if (length(inv) == 0) {
  cat("Centroide : aucune inversion.\n")
} else {
  cat("Nombre d'inversions :", length(inv), "\n")
  for (i in inv) {
    cat("  Etape", i,   ": h =", round(h[i],   4), "\n")
    cat("  Etape", i+1, ": h =", round(h[i+1], 4),
        "<-- INVERSION\n")
  }
}

#Ward

hc_ward <- hclust(delta_usa, method = "ward.D2")
g_ward  <- cutree(hc_ward, k = 3)

plot(hc_ward,
     main  = "CAH - Méthode de Ward",
     xlab  = "",
     sub   = "",
     ylab  = "Hauteur",
     cex   = 0.7,
     hang  = -1)
rect.hclust(hc_ward, k = 3,
            border = c("blue", "red", "darkgreen"))

cat("Ward — effectifs :", table(g_ward), "\n")


# TABLEAU COMPARATIF

tableau <- data.frame(
  Etat      = rownames(USArrests),
  Single    = g_single,
  Complete  = g_complete,
  Average   = g_average,
  Centroide = g_centroid,
  Ward      = g_ward
)
print(tableau)

