# updt_psacn_macos

Ce script est une aide pour appliquer les mises à jour du Connect Nav des véhicules PSA sous macOS. En effet, le formatage de la clé USB, ainsi que les fichiers commençant par ._ laissés par macOS gênent les mises à jour du Connect Nav.

# Détail

Pour ceux qui sont sous Mac, j'ai créé ce script pour aider à formater une clé USB et y extraire la mise à jour. Attention, le script va formater la clé USB, donc il est potentiellement dangereux pour vos données! Mais j'ai essayé de le rendre aussi sûr que possible. De plus, j'ai développé ce script pour qu'il ne demande aucun mot de passe administrateur. Si il le fait, ce n'est pas normal! Il y a alors un risque que vous n'exécutiez pas le bon script ou que quelqu'un de mal intentionné l'ai détourné.
Dans tous les cas, ce script est à utiliser à vos risques et périls. Je ne serai pas responsable en cas de perte de données.

Pour commencer, télécharger le script ici :
https://github.com/macjl/updt_psacn_macos/archive/master.zip

La première fois, ouvrez le script avec un 'Clic-droit' puis 'Ouvrir' et confirmer par 'Ouvrir'. Si vous ne ne faites pas ainsi, macOS ne voudra pas l'ouvrir pour des questions de sécurité.
Par la suite, vous pourrez l'ouvrir directement en double cliquant dessus.

Ensuite, le script fonctionne en trois phases :
- La première option permet de formater la clé USB au bon format
- La deuxième option permet de copier le fichier des carte ou du firmware dans la clé, en supprimant les fichiers cachés qui pourraient bloquer l'installation.
- La troisième option permet d'ajouter le fichier de licence si il est nécessaire.

Pour effectuer ces trois étapes, il faut relancer le script entre chaques. Normalement, le script guide assez bien l'utilisateur pour ne pas avoir a en détailler le fonctionnement ici.
