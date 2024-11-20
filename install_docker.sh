#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Variablen
DOCKER_USER="dockeradmin"
DOCKER_GROUP="docker"
DOCKER_COMPOSE_VERSION="v2.20.2"  # Spezifische Docker Compose Version

# Funktionen für farbige Ausgaben
echo_info() {
    echo -e "\e[34m[INFO]\e[0m $1"
}

echo_success() {
    echo -e "\e[32m[SUCCESS]\e[0m $1"
}

echo_error() {
    echo -e "\e[31m[ERROR]\e[0m $1" >&2
}

# Sicherstellen, dass das Skript als Root ausgeführt wird
if [[ "$EUID" -ne 0 ]]; then
    echo_error "Dieses Skript muss als root ausgeführt werden."
    exit 1
fi

# System aktualisieren
echo_info "System wird aktualisiert..."
apt update && apt upgrade -y

# Notwendige Abhängigkeiten installieren
echo_info "Notwendige Abhängigkeiten werden installiert..."
apt install -y ca-certificates curl gnupg lsb-release

# Docker GPG-Schlüssel hinzufügen
echo_info "Docker GPG-Schlüssel wird hinzugefügt..."
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Docker Repository hinzufügen
echo_info "Docker Repository wird hinzugefügt..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Paketliste aktualisieren
echo_info "Paketliste wird aktualisiert..."
apt update

# Docker Engine, CLI und Containerd installieren
echo_info "Docker Engine, CLI und Containerd werden installiert..."
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Docker-Dienst starten und aktivieren
echo_info "Docker-Dienst wird gestartet und aktiviert..."
systemctl start docker
systemctl enable docker

# Erstellen des separaten Docker-Benutzers
echo_info "Erstellen des Docker-Benutzers '$DOCKER_USER'..."
if id "$DOCKER_USER" &>/dev/null; then
    echo_info "Benutzer '$DOCKER_USER' existiert bereits."
else
    useradd -m -s /bin/bash "$DOCKER_USER"
    echo_success "Benutzer '$DOCKER_USER' wurde erstellt."
fi

# Erstellen der Docker-Gruppe, falls nicht vorhanden
echo_info "Überprüfen der Docker-Gruppe..."
if getent group "$DOCKER_GROUP" >/dev/null; then
    echo_info "Gruppe '$DOCKER_GROUP' existiert bereits."
else
    groupadd "$DOCKER_GROUP"
    echo_info "Gruppe '$DOCKER_GROUP' wurde erstellt."
fi

# Benutzer zur Docker-Gruppe hinzufügen
echo_info "Benutzer '$DOCKER_USER' wird zur Gruppe '$DOCKER_GROUP' hinzugefügt..."
usermod -aG "$DOCKER_GROUP" "$DOCKER_USER"
echo_success "Benutzer '$DOCKER_USER' wurde zur Gruppe '$DOCKER_GROUP' hinzugefügt."

# Setzen der richtigen Berechtigungen für Docker-Socket
echo_info "Setzen der Berechtigungen für den Docker-Socket..."
chown root:"$DOCKER_GROUP" /var/run/docker.sock
chmod 660 /var/run/docker.sock

# Docker Compose als Plugin ist bereits installiert, Überprüfung
echo_info "Überprüfen der Docker Compose Installation..."
docker compose version

# Hinweis zu benötigten Firewall-Ports
echo_success "Docker und Docker Compose wurden erfolgreich installiert."
echo_info "Bitte stellen Sie sicher, dass folgende Ports in Ihrer externen Firewall freigegeben sind:"
echo -e "  - 22/tcp (SSH)\n  - 80/tcp (HTTP)\n  - 443/tcp (HTTPS)"
echo_info "Weitere Ports können je nach Ihren spezifischen Anwendungen erforderlich sein."

# Test der Docker-Installation
echo_info "Testen der Docker-Installation mit dem 'hello-world' Container..."
sudo -u "$DOCKER_USER" docker run --rm hello-world
echo_success "Docker-Installation wurde erfolgreich getestet."

# Hinweis zur Aktivierung der Gruppenzugehörigkeit
echo -e "\n\e[33mBitte melden Sie sich als '$DOCKER_USER' an oder führen Sie 'newgrp docker' aus, um die Gruppenzugehörigkeit zu aktualisieren.\e[0m"
