#!/bin/bash
# Script pour générer les fichiers du dépôt APT

set -e

# Répertoire racine du projet
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "$(cd "$(dirname "$0")/.." && pwd)")
cd "$REPO_ROOT"

# Configuration
DIST_NAME="stable"
COMPONENT="main"
ARCH="amd64"
GPG_KEY_EMAIL="${GPG_KEY_EMAIL:-axelfrache@gmail.com}"
REPO_NAME="Pinky APT Repository"

# Création des répertoires s'ils n'existent pas
mkdir -p "dists/$DIST_NAME/$COMPONENT/binary-$ARCH"
mkdir -p "pool/$COMPONENT"

echo "🔍 Génération des fichiers Packages..."

# Génération du fichier Packages
dpkg-scanpackages --arch "$ARCH" "pool/$COMPONENT" > "dists/$DIST_NAME/$COMPONENT/binary-$ARCH/Packages" 2>/dev/null

# Compression du fichier Packages
gzip -9c "dists/$DIST_NAME/$COMPONENT/binary-$ARCH/Packages" > "dists/$DIST_NAME/$COMPONENT/binary-$ARCH/Packages.gz"

echo "📝 Génération du fichier Release..."

# Date actuelle au format UTC (plus compatible)
DATE=$(date -u '+%a, %d %b %Y %H:%M:%S UTC')

# Création du fichier Release
cat > "dists/$DIST_NAME/Release" << EOF
Origin: $REPO_NAME
Label: $REPO_NAME
Suite: $DIST_NAME
Codename: $DIST_NAME
Date: $DATE
Architectures: $ARCH
Components: $COMPONENT
Description: $REPO_NAME
EOF

{
  echo "MD5Sum:"
  find "dists/$DIST_NAME" -type f -not -path "*/Release*" -exec bash -c 'echo " $(md5sum "$1" | cut -d" " -f1) $(stat -c%s "$1") ${1#dists/stable/}"' _ {} \;
  echo "SHA1:"
  find "dists/$DIST_NAME" -type f -not -path "*/Release*" -exec bash -c 'echo " $(sha1sum "$1" | cut -d" " -f1) $(stat -c%s "$1") ${1#dists/stable/}"' _ {} \;
  echo "SHA256:"
  find "dists/$DIST_NAME" -type f -not -path "*/Release*" -exec bash -c 'echo " $(sha256sum "$1" | cut -d" " -f1) $(stat -c%s "$1") ${1#dists/stable/}"' _ {} \;
} >> "dists/$DIST_NAME/Release"

if gpg --list-secret-keys "$GPG_KEY_EMAIL" > /dev/null 2>&1; then
  echo "🔐 Signature du fichier Release avec GPG..."
  gpg --default-key "$GPG_KEY_EMAIL" -abs -o "dists/$DIST_NAME/Release.gpg" "dists/$DIST_NAME/Release"
  gpg --default-key "$GPG_KEY_EMAIL" --clearsign -o "dists/$DIST_NAME/InRelease" "dists/$DIST_NAME/Release"
  echo "✅ Signature GPG terminée."
else
  echo "⚠️  Aucune clé GPG trouvée pour $GPG_KEY_EMAIL. Le dépôt n'est pas signé."
  echo "   Utilisez 'make generate-keys' pour créer une paire de clés GPG."
fi

echo "✅ Génération du dépôt APT terminée."