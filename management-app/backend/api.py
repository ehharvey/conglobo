import json
import os
from pathlib import Path
import socket
from flask import Flask, abort, jsonify, request, send_file, send_from_directory
from flask_cors import CORS, cross_origin
import socket

from app_management.app_container import AppContainer
from app_management.app import App

from app_management.app_manager import (
    AppAlreadyActivated,
    AppAlreadyDeactivated,
    AppManager,
)
import conglobo_environment

hostname = socket.gethostname()
IPAddr = socket.gethostbyname(hostname)

# Get Config from environment variables
config = conglobo_environment.getOsConfig()


app = Flask(__name__)

cors = CORS(app)
app.config["CORS_HEADERS"] = "Content-Type"

# App Management demo
manager = AppManager(config)


@app.route("/healthcheck", methods=["GET"])
def healthcheck():
    return jsonify({"message": "OK"}), 200


# Gets the active-services and their statuses
@app.route("/apps", methods=["GET"])
def get_apps():
    try:
        apps = manager.apps
    except Exception as e:
        return jsonify({"message": f"Could not get apps: {e}"}), 500

    return json.dumps([a.dict() for a in apps]), 200  # OK


@app.route("/apps/<app_name>", methods=["DELETE"])
def deactivate_app(app_name):
    try:
        manager.deactivate_app(app_name)
    except AppAlreadyDeactivated:
        return jsonify({"message": "App already deactivated"}), 400
    except Exception as e:
        return jsonify({"message": f"Could not deactivate app: {e}"}), 500

    return jsonify({"message": "App deleted"}), 200


@app.route("/apps/<app_name>", methods=["POST"])
def activate_app(app_name):
    try:
        app = next(a for a in manager.app_configs if a.name == app_name)
    except StopIteration:
        return jsonify({"message": "App not found"}), 404

    try:
        manager.activate_app(app)
    except AppAlreadyActivated:
        return jsonify({"message": "App already activated"}), 400
    except Exception as e:
        return jsonify({"message": f"Could not activate app: {e}"}), 500

    return jsonify({"message": "App created"}), 201


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=config.port)
