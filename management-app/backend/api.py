import json
import os
from pathlib import Path
import socket
from flask import Flask, abort, jsonify, request, send_file, send_from_directory
import socket

from app_management.app_container import AppContainer
from app_management.app import App

from app_management.app_manager import AppManager
import conglobo_environment

hostname = socket.gethostname()
IPAddr = socket.gethostbyname(hostname)
config = conglobo_environment.getOsConfig()

port = 8000
app = Flask(__name__, static_folder="../frontend/build/web")

node = {"ip": IPAddr, "health": "Good", "status": True}

with open("config/active-apps.json", "r") as f:
    active_apps = json.load(f)

app_manager = AppManager(config.config_directory)

# App Management demo
manager = AppManager(config)
test_app = App(
    name="testapp",
    # URL is messy right now because it includes regex
    # that nginx can use to rewrite the route strings
    # TODO: Perform this on app-side?
    url_path=r"/testapp(.*)",
    container=AppContainer(image="strm/helloworld-http", volumes=[], port=80),
)
try:
    manager.delete_app(test_app.name)
except:
    pass
try:
    manager.add_app(test_app)
except:
    pass


# Flutter Serving


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
    apps = app_manager.get_apps()
    active_apps = {app.name: {"status": app.is_running()} for app in apps}
    return jsonify(active_apps), 200  # OK


# Gets all the avaliable services in the services file
@app.route("/services", methods=["GET"])
def get_services():
    return (config.config_directory / "services.json").read_text()


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=port)
