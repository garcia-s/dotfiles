import os
import json
import sys

def get_apps():
    dirs = [
        "/usr/share/applications",
        os.path.expanduser("~/.local/share/applications"),
        "/var/lib/flatpak/exports/share/applications"
    ]
    
    apps = {}
    for d in dirs:
        if not os.path.isdir(d):
            continue
        for f in os.listdir(d):
            if not f.endswith(".desktop"):
                continue
            path = os.path.join(d, f)
            if path in apps:
                continue
            
            app = {"name": "", "exec": "", "icon": "application-x-executable"}
            try:
                with open(path, "r", errors="ignore") as file:
                    # Only parse the [Desktop Entry] section
                    in_desktop_entry = False
                    for line in file:
                        line = line.strip()
                        if line == "[Desktop Entry]":
                            in_desktop_entry = True
                            continue
                        if line.startswith("[") and line.endswith("]"):
                            in_desktop_entry = False
                            continue
                        
                        if in_desktop_entry and "=" in line:
                            key, val = line.split("=", 1)
                            key = key.strip()
                            val = val.strip()
                            
                            # We only want the primary Name (no localization)
                            if key == "Name" and not app["name"]:
                                app["name"] = val
                            elif key == "Exec" and not app["exec"]:
                                app["exec"] = val
                            elif key == "Icon" and not app["icon"]:
                                app["icon"] = val
                                
                    if app["name"] and app["exec"]:
                        apps[path] = app
            except Exception:
                continue
    
    return sorted(list(apps.values()), key=lambda x: x["name"].lower())

if __name__ == "__main__":
    print(json.dumps(get_apps()))
