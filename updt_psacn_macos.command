#!/bin/bash
#set -vx

format () {
	clear
	echo "Recherche des Clée USB"
	TMPFILE=$(mktemp) || exit 1

	for i in $( diskutil list external physical | grep "(external, physical)"| awk '{ print $1}' | cut -c 6- )
	do
		printf "$i," >> $TMPFILE
		for j in $(diskutil list $i | tail -n +3 | awk '{ print $NF}')
		do
			PARTNAME=$( diskutil info $j | grep "Volume Name" | grep -v "Not applicable (no file system)" | grep "Volume Name:" | sed "s/Volume Name://;s/^ *//")
			if [ "$PARTNAME" != "" ] ; then
				printf "\"$PARTNAME\"/" >> $TMPFILE
			fi
		done
		echo >> $TMPFILE
	done

	echo
	echo "Parmis ces clés USB, laquelle doit être formatée ?"

	cat $TMPFILE | while read line
	do
		DISKID=$( echo $line | awk -F "," '{ print $1 }' )
		PARTLIST=$( echo $line | awk -F "," '{ print $2}' | sed "s/\//, /g;s/, $//")
		echo " - $DISKID # Contient les volumes suivants : $PARTLIST"
	done
	echo "Attention!! Toutes les données de la clé seront perdues!!"

	echo
	echo "Choisir la clé :"
	PS3="Choix: "
	select opt in $( cat $TMPFILE | awk -F "," '{ print $1 }' ) "Annuler"
	do
		if [ "$opt" != "" ] ; then
			DISKTARGET=$opt
			break
		fi
	done

	rm $TMPFILE

	if [ ! -e /dev/"$DISKTARGET" ] ; then
		echo "Annulation"
	else
		echo "Formatage du disque $DISKTARGET"
		echo "Vous avez encore 10 secondes pour annuler avec la combinaison \"ctrl+c\""
		d=10
		while [ $d -gt 0 ] ; do echo $d ; d=$(( $d -1 )) ; sleep 1 ; done

		diskutil partitionDisk $DISKTARGET MBR FAT32 PSAUPDT 100%
		RC=$?

		if [ $RC -eq 0 ] && [ -d /Volumes/PSAUPDT ]
		then
			echo
			echo "Formatage réussi! La clé USB qui recevra les mise à jour s'appelle maintenant \"PSAUPDT\""
		else
			echo
			echo "Formatage echoué. Recommencer l'opération"
			exit 32
		fi
	fi
}

expand() {
	clear
	VOLUME=/Volumes/PSAUPDT

	if [ ! -d "$VOLUME" ] ; then
		echo "Pas de clé USB nommée \"PSAUPDT\" trouvée. Veuillez la formater au préalable avec cet utilitaire"
	else
		echo "Glisser et déposer ici le fichier \".tar\" de mise à jour, puis appuyer sur la touche Entrée"
		read SOURCE

		if [ ! -e "$SOURCE" ] ; then
			echo "Pas de fichier de mise à jour trouvé. Veuillez le télécharger sur le site de votre constructeur automobile, et le renseigner ici."
		else

			DISKFREE=$( df -k "$VOLUME" | tail -n 1 | awk '{ print $4 }' )
			UPDTSIZE=$( du -k "$SOURCE" | awk '{ print $1}' )

			if [ $UPDTSIZE -gt $DISKFREE ] ; then
				echo "La clée USB n'est pas assez capacitive pour recevoir cette mise à jour"
			else

				echo
				echo
				echo "Extraction de la mise à jour dans la clé. Cela peut prendre quelques minutes"
				cd "$VOLUME"
				tar -vxf "$SOURCE"
				RC=$?

				if [ $RC -ne 0 ] ; then
					echo
					echo "L'extraction a échouée. Vérifier les messages précédents pour comprendre la raison de l'échec"
				fi
			fi
		fi
	fi
}

eject() {

					if [ -d /Volumes/PSAUPDT ]
					then
						cd /Volumes/PSAUPDT
						find . -name "._*" -exec rm -v {} \; 2>/dev/null
						rm -fr .Trashes .fseventsd
						cd -
						sleep 5
						diskutil eject /Volumes/PSAUPDT
						echo "Opération terminée. Vous pouvez retirer la clé USB et l'insérer dans votre véhicule"
					else
						echo "Clee non trouvée"
					fi
}


license() {
	clear
	VOLUME=/Volumes/PSAUPDT

	if [ ! -d "$VOLUME" ] ; then
		echo "Pas de clé USB nommée \"PSAUPDT\" trouvée. Veuillez la formater au préalable avec cet utilitaire"
	else
		echo "Glisser et déposer ici le fichier license, puis appuyer sur la touche Entrée"
		read SOURCE

		if [ ! -e "$SOURCE" ] ; then
			echo "Pas de fichier de license trouvé. Veuillez le télécharger sur le site de votre constructeur automobile, et le renseigner ici."
		else
			mkdir /Volumes/PSAUPDT/license
			LICTARG="$( basename $SOURCE | sed 's/\.key.*$/.key/') "
			cp $SOURCE /Volumes/PSAUPDT/license/$LICTARG
			if [ $? -eq 0 ] ; then
				echo "Fichier de license correctement installé dans la clé USB. Vous pouvez passer à la troisième étape."
			else
				echo "La copie du fichier license a échoué sur la clé USB"
			fi
		fi
	fi
}

REPLY=0

while [ $REPLY != 5 ]
do
	clear
	echo "Que souhaitez vous faire?"
	PS3="Choix : "
	select opt in "Formater la clé USB" "Copier l'éventuel fichier de license" "Copier la mise à jour dans la clé" "Ejecter la Clé" "Quitter"
	do
		case $REPLY in
			1 ) format ; break;;
			2 ) license ; break;;
			3 ) expand ; break;;
			4 ) eject ; break;;
			5 ) break ;;
			*) echo "Option invalide" ; continue
		esac
	done
	[ $REPLY -lt 5 ] && sleep 4
done

echo
echo "###########################################################"
read -p 'Appuyer sur entrée pour fermer la fenêtre.'
osascript -e 'tell application "Terminal" to close front window' > /dev/null 2>&1 &
