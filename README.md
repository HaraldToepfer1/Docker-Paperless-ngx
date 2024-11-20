Ausführung des Skripts
Speichern des Skripts: Speichern Sie das Skript in einer Datei, z.B. install_docker.sh.

bash
Code kopieren
nano install_docker.sh
Fügen Sie den obigen Inhalt ein und speichern Sie die Datei (z.B. mit CTRL + O, dann ENTER und CTRL + X zum Beenden).

Ausführbar machen: Machen Sie das Skript ausführbar.

bash
Code kopieren
chmod +x install_docker.sh
Ausführen des Skripts: Führen Sie das Skript als Root aus.

bash
Code kopieren
./install_docker.sh
Nach der Ausführung:

Melden Sie sich als der neu erstellte Benutzer dockeradmin an oder verwenden Sie newgrp docker, um die Gruppenzugehörigkeit ohne Ab- und Anmeldung zu aktualisieren.

Überprüfen Sie die Docker-Installation mit:

bash
Code kopieren
docker run hello-world
docker compose version
