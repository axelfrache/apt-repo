# Dépôt APT Personnel

Un dépôt APT sécurisé, signé avec GPG, pour héberger et distribuer vos paquets `.deb` personnalisés via Docker + Nginx.

## Structure

```
apt-repo/
├── dists/               # Métadonnées APT
├── pool/                # Paquets .deb
├── keys/                # Clés GPG (publique/privée)
├── scripts/             # Génération du dépôt
├── nginx/               # Config Nginx
├── docker-compose.yml   # Déploiement Docker
├── Makefile             # Commandes utiles
└── README.md
```

## Prérequis

- `dpkg-dev`, `gnupg`, `gzip`
- `docker` et `docker-compose`

```bash
sudo apt install dpkg-dev gnupg gzip
```

## Utilisation

### Générer la clé GPG

```bash
make generate-keys
```

### Ajouter un paquet

```bash
cp votre-paquet.deb pool/main/
make update
```

### Mettre à jour le dépôt

```bash
make update
```

## Héberger avec Docker

### Démarrer le serveur

```bash
docker-compose up -d
```

- Local : http\://localhost:8080
- Réseau : http\://\<IP\_DU\_SERVEUR>:8080

### Stopper ou observer

```bash
docker-compose down
docker-compose logs -f
```

## Maintenance

```bash
make rebuild    # Recrée entièrement le dépôt
make clean      # Nettoie les fichiers générés
```

# Ajouter ce dépôt sur un client APT

## Installer la clé publique

```bash
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://aptrepo.axelfrache.me/keys/public.key | gpg --dearmor \
  | sudo tee /etc/apt/keyrings/frache-repo.gpg > /dev/null
```

## Ajouter la source APT

```bash
echo "deb [signed-by=/etc/apt/keyrings/frache-repo.gpg] https://aptrepo.axelfrache.me stable main" \
  | sudo tee /etc/apt/sources.list.d/frache-repo.list > /dev/null
```

## Mettre à jour

```bash
sudo apt update
```

## Installer un paquet

```bash
sudo apt install frache-time
```

## Vérifier la clé

```bash
gpg --show-keys /etc/apt/keyrings/frache-repo.gpg
```

## Supprimer le dépôt

```bash
sudo rm /etc/apt/sources.list.d/frache-repo.list
sudo rm /etc/apt/keyrings/frache-repo.gpg
sudo apt update
```