# Données

Placer ici le fichier **`decath.Rda`**, chargé par les scripts `01_ACP.R`, `02_CAH.R`, `03_K-means.R` et `04_DBSCAN.R` avec :

```r
load("decath.Rda")
```

Ce fichier contient le data frame `decathlon` : 41 athlètes (en noms de lignes) décrits par 13 variables.

| Variables | Description |
|---|---|
| `X100m`, `Longueur`, `Poids`, `Hauteur`, `X400m`, `X110m.H`, `Disque`, `Perche`, `Javelot`, `X1500m` | Performances aux 10 épreuves (secondes ou mètres) |
| `Points` | Score total (retiré avant l'analyse) |
| `Classement` | Classement (retiré avant l'analyse) |
| `Competition` | Compétition : Jeux Olympiques (28 athlètes) ou Decastar (13 athlètes) |

Le script `USArrests_criteres_agregation.R` n'a pas besoin de ce fichier : il utilise le jeu de données `USArrests` intégré à R.
