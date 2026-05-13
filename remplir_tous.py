#!/usr/bin/env python3
import os
from pathlib import Path

print("🚀 Remplissage de tous les fichiers...")

# Fonction helper
def create_file(path, content):
    Path(path).write_text(content)
    print(f"✅ {path}")

# Le script continuera dans le prochain message...
print("✅ Script créé")
