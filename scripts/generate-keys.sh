#!/bin/bash
# Script pour générer les clés GPG pour le dépôt APT

set -e

# Répertoire racine du projet
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "$(cd "$(dirname "$0")/.." && pwd)")
cd "$REPO_ROOT"

# Configuration
GPG_KEY_EMAIL="${GPG_KEY_EMAIL:-axelfrache@gmail.com}"
GPG_KEY_NAME="${GPG_KEY_NAME:-Pinky APT Repository}"
GPG_KEY_COMMENT="${GPG_KEY_COMMENT:-APT Repository Signing Key}"
KEY_DIR="$REPO_ROOT/keys"

# Création du répertoire des clés s'il n'existe pas
mkdir -p "$KEY_DIR"

echo "🔑 Génération de la paire de clés GPG..."

# Nettoyer les clés existantes pour l'email spécifié
FINGERPRINTS=$(gpg --list-secret-keys --with-colons "$GPG_KEY_EMAIL" 2>/dev/null | grep -E '^fpr:' | cut -d: -f10)

if [ -n "$FINGERPRINTS" ]; then
    echo "⚠️  Des clés GPG existent déjà pour $GPG_KEY_EMAIL."
    read -p "Voulez-vous les remplacer ? (o/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Oo]$ ]]; then
        echo "❌ Opération annulée."
        exit 0
    fi
    
    # Supprimer toutes les clés existantes pour cet email
    for FPR in $FINGERPRINTS; do
        echo "Suppression de la clé $FPR..."
        gpg --batch --yes --delete-secret-keys "$FPR" 2>/dev/null || true
        gpg --batch --yes --delete-keys "$FPR" 2>/dev/null || true
    done
    echo "🗑️  Clés existantes supprimées."
fi

# Générer une nouvelle paire de clés
cat > /tmp/gpg-gen-key.batch << EOF
%echo Generating GPG key for $GPG_KEY_EMAIL
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: $GPG_KEY_NAME
Name-Comment: $GPG_KEY_COMMENT
Name-Email: $GPG_KEY_EMAIL
Expire-Date: 0
%no-ask-passphrase
%no-protection
%commit
%echo Done
EOF

gpg --batch --gen-key /tmp/gpg-gen-key.batch
rm -f /tmp/gpg-gen-key.batch

# Récupérer le fingerprint de la clé nouvellement créée
FINGERPRINT=$(gpg --list-secret-keys --with-colons "$GPG_KEY_EMAIL" | grep -E '^fpr:' | head -n1 | cut -d: -f10)
KEY_ID=$(echo "$FINGERPRINT" | tail -c 17)

if [ -z "$FINGERPRINT" ]; then
    echo "⚠️ Erreur: Impossible de trouver la clé GPG pour $GPG_KEY_EMAIL"
    exit 1
fi

# Exporter la clé publique
gpg --armor --export "$GPG_KEY_EMAIL" > "$KEY_DIR/public.key"

echo "✅ Génération de la clé GPG terminée."
echo "📋 Clé publique exportée dans $KEY_DIR/public.key"
echo "🔑 ID de la clé: $KEY_ID"
echo "🔒 Fingerprint complet: $FINGERPRINT"
echo
echo "Pour utiliser cette clé sur un autre système:"
echo "curl -fsSL https://aptrepo.axelfrache.me/keys/public.key | sudo apt-key add -"
