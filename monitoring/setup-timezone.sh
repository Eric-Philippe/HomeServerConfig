#!/bin/bash

# Nom du fichier de timezone
TIMEZONE="Europe/Paris"

# Chemin du fichier de timezone
TZ_PATH="/usr/share/zoneinfo/$TIMEZONE"

# Vérifie si le fichier de timezone existe
if [ ! -f "$TZ_PATH" ]; then
  echo "Le fichier de timezone $TIMEZONE n'existe pas. Vérifiez votre fuseau horaire."
  exit 1
fi

# Liste tous les conteneurs Docker en cours d'exécution
CONTAINERS=$(docker ps -q)

# Vérifie si des conteneurs sont en cours d'exécution
if [ -z "$CONTAINERS" ]; then
  echo "Aucun conteneur en cours d'exécution."
  exit 0
fi

# Parcourt chaque conteneur et met à jour le fuseau horaire
for CONTAINER in $CONTAINERS; do
  echo "Mise à jour du fuseau horaire pour le conteneur $CONTAINER"
  docker exec $CONTAINER bash -c "ln -sf $TZ_PATH /etc/localtime && echo \"$TIMEZONE\" > /etc/timezone"
  if [ $? -eq 0 ]; then
    echo "Fuseau horaire mis à jour pour le conteneur $CONTAINER"
  else
    echo "Erreur lors de la mise à jour du fuseau horaire pour le conteneur $CONTAINER"
  fi
done

echo "Mise à jour terminée."
