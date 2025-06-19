# Pinky APT Repository

Un dépôt APT local sécurisé avec GPG pour héberger des paquets Debian personnalisés.

## Structure

```
pinky-apt-repo/
├── dists/               # Métadonnées du dépôt
├── pool/                # Stockage des paquets .deb
├── keys/                # Clés GPG pour la signature
├── scripts/             # Scripts d'automatisation
├── .gitignore
├── README.md
└── Makefile             # Automatisation des tâches
```

## Prérequis

- `dpkg-dev` : Outils de développement Debian
- `apt-utils` : Utilitaires APT
- `gnupg` : Gestion des clés GPG
- `gzip` : Compression des fichiers

```bash
sudo apt-get install dpkg-dev apt-utils gnupg gzip
```

## Configuration

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

## Utilisation

Pour utiliser ce dépôt sur un autre système :

1. Ajouter la clé GPG :
   ```bash
   curl -fsSL https://aptrepo.axelfrache.me/keys/public.key | sudo apt-key add -
   ```

2. Ajouter le dépôt :
   ```bash
   echo "deb https://aptrepo.axelfrache.me stable main" | sudo tee /etc/apt/sources.list.d/pinky-apt-repo.list
   ```

3. Mettre à jour et installer :
   ```bash
   sudo apt-get update
   sudo apt-get install nom-du-paquet
   ```

## Maintenance

- Pour reconstruire entièrement le dépôt : `make rebuild`
- Pour nettoyer les fichiers générés : `make clean`
