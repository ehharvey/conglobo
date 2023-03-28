import os
import socket
import json
from flask import Flask, abort, jsonify, request, send_from_directory
from app_management import AppManager, AppVolume, App, AppContainer
from conglobo_environment import CongloboEnvironment
import yaml

hostname = socket.gethostname()
IPAddr = socket.gethostbyname(hostname)
Config_Loc = (
    "/workspaces/GoogleSolutionChallenge2023/management-app/minikube/config.yaml"
)

port = 8000
app = Flask(__name__, static_folder="../frontend/build/web")

node = {"ip": IPAddr, "health": "Good", "status": True}

with open(Config_Loc, "r") as f:
    config = yaml.safe_load(f)

active_apps = config["data"]["config"]

app_manager = AppManager(CongloboEnvironment())

# Flutter Serving -----------------


@app.route("/")
def serve_flutter_build():
    return send_from_directory(app.static_folder, "index.html")


@app.route("/<path:path>")
def send_report(path):
    return send_from_directory(app.static_folder, path)


#  API Routes - ---------------------


@app.route("/health-check")
def health_check():
    return jsonify(node)


# Node activation and deactivation


@app.route("/node/activate", methods=["POST"])
def activate_node():
    node["status"] = True
    return jsonify(node)


@app.route("/node/deactivate", methods=["POST"])
def deactivate_node():
    node["status"] = False
    return jsonify(node)


# Gets the active-apps and their statuses
@app.route("/active-apps", methods=["GET"])
def get_active_apps():
    with open(Config_Loc, "r") as f:
        active_apps_yaml = yaml.safe_load(f)["data"]["config"]

    active_apps = yaml.safe_load(active_apps_yaml)
    active_apps_json = json.dumps(active_apps)

    return active_apps_json, 200


# Change the active status of an app


@app.route("/active-apps/toggle", methods=["POST"])
def set_active_app():
    title = request.args.get("title")
    status = request.args.get("status")

    with open(Config_Loc, "r") as f:
        data = yaml.safe_load(f)

    # Update the status for the app with matching title
    app_config = data["data"]["config"]
    active_apps = json.loads(app_config)

    if title in active_apps:
        active_apps[title]["status"] = status == "true"

    # Write the updated data to the YAML file
    with open(Config_Loc, "w") as f:
        data["data"]["config"] = json.dumps(active_apps)
        yaml.dump(data, f)

    return active_apps[title]


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=port)
