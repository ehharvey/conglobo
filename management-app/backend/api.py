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

    if not title or not status:
        abort(400)  # Bad request

    active_apps = config["data"]["config"]

    # Get matching app by title
    matching_dict = next((d for d in active_apps if d.get(title)), None)
    if not matching_dict:
        abort(404)  # Not found

    # Toggle the status boolean value
    if matching_dict[title]["status"]:
        matching_dict[title]["status"] = False
    else:
        matching_dict[title]["status"] = True

    with open(Config_Loc, "w") as f:
        active_apps_yaml = yaml.dump({"config": active_apps})
        f.write(active_apps_yaml)

    # # Get app by name from AppManager
    # app = app_manager.get_app(title)
    # if not app:
    #     abort(404)

    # # Set app status based on request
    # if status == "true":
    #     if not app_manager.get_app(title):
    #         app_manager.add_app(app)
    # else:
    #     app_manager.delete_app(name=title)

    return jsonify({"status": "success"}), 200


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=port)
