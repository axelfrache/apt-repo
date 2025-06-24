# Dépôt APT Personnel

Un dépôt APT local sécurisé avec GPG pour héberger des paquets Debian personnalisés.

## Structure

```
apt-repo/
│── dists/               # Métadonnées du dépôt
│── pool/                # Stockage des paquets .deb
│── keys/                # Clés GPG pour la signature
│── scripts/             # Scripts d'automatisation
│── nginx/               # Configuration Nginx
│   └── default.conf      # Fichier de config Nginx
│── docker-compose.yml    # Définition des services Docker
│── .gitignore
│── README.md
└── Makefile             # Automatisation des tâches
```

## Prérequis pour le développement

- `dpkg-dev` : Outils de développement Debian
- `apt-utils` : Utilitaires APT
- `gnupg` : Gestion des clés GPG
- `gzip` : Compression des fichiers
- `docker` et `docker-compose` : Pour l'hébergement local

```bash
sudo apt-get install dpkg-dev apt-utils gnupg gzip
```

## Configuration du dépôt

1. Générer une paire de clés GPG pour signer le dépôt :
   ```bash
   make generate-keys
   ```

2. Ajouter des paquets .deb au dépôt :
   ```bash
   cp votre-paquet.deb pool/main/
   make update
   ```

3. Mettre à jour le dépôt après ajout/suppression de paquets :
   ```bash
   make update
   ```

## Hébergement avec Docker

Le dépôt peut être facilement hébergé via Nginx dans un conteneur Docker :

1. Démarrer le serveur Nginx :
   ```bash
   docker-compose up -d
   ```

2. Accéder au dépôt :
   - Localement : http://localhost:8080
   - Depuis un autre poste sur le réseau : http://<IP_DU_SERVEUR>:8080

3. Arrêter le serveur :
   ```bash
   docker-compose down
   ```

4. Visualiser les logs :
   ```bash
   docker-compose logs -f
   ```

## Maintenance

- Pour reconstruire entièrement le dépôt : `make rebuild`
- Pour nettoyer les fichiers générés : `make clean`

---

# 🧩 Guide d'installation – Dépôt APT Personnel

Ce guide vous explique comment ajouter ce dépôt APT sur une distribution Debian ou Ubuntu, en toute sécurité via une clé GPG.

## 🔑 Pourquoi une signature GPG ?

APT (le gestionnaire de paquets de Debian/Ubuntu) refuse d'installer des paquets depuis des dépôts non signés ou dont la clé de confiance n'est pas connue.
C'est une protection contre les dépôts falsifiés ou modifiés.

Chaque dépôt est signé avec une clé privée GPG, et les clients APT vérifient cette signature avec la clé publique correspondante.

## ✅ Étapes d'installation

### 1. Télécharger et installer la clé publique du dépôt

Cette clé permet à votre système de vérifier l'authenticité des paquets.

```bash
sudo mkdir -p /etc/apt/keyrings

curl -fsSL https://aptrepo.axelfrache.me/keys/public.key \
  | gpg --dearmor | sudo tee /etc/apt/keyrings/axelfrache.gpg > /dev/null
```

### 2. Ajouter le dépôt APT

Créez un fichier de source dédié pour ce dépôt :

```bash
echo "deb [signed-by=/etc/apt/keyrings/axelfrache.gpg] https://aptrepo.axelfrache.me stable main" \
  | sudo tee /etc/apt/sources.list.d/axelfrache.list > /dev/null
```

### 3. Mettre à jour la liste des paquets

```bash
sudo apt update
```

Si tout est correct, aucune erreur GPG ne s'affichera, et les paquets du dépôt seront disponibles.

### 4. (Optionnel) Installer un paquet depuis le dépôt

Par exemple :

```bash
sudo apt install nom-du-paquet
```

_(Remplacez nom-du-paquet par le nom réel du paquet souhaité)_

## 🔐 Vérifier la clé utilisée

Pour voir les détails de la clé installée :

```bash
gpg --show-keys /etc/apt/keyrings/axelfrache.gpg
```

Vous devriez voir une empreinte correspondant à :

```
026266C4599FDBB2
```

## 🧼 Désinstallation du dépôt

Pour supprimer le dépôt et la clé :

```bash
sudo rm /etc/apt/sources.list.d/axelfrache.list
sudo rm /etc/apt/keyrings/axelfrache.gpg
sudo apt update
```
