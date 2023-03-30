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

# Get Config from environment variables
config = conglobo_environment.getOsConfig()


app = Flask(__name__, static_folder="../frontend/build/web")

node = {"ip": IPAddr, "health": "Good", "status": True}

with open("services.json", "r") as f:
    services = json.load(f)

with open("active-services.json", "r") as f:
    active_services = json.load(f)

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


# API Routes


@app.route("/health-check")
def health_check():
    return jsonify(node)


@app.route("/node/activate", methods=["POST"])
def activate_node():
    node["status"] = True
    return jsonify(node)


@app.route("/node/deactivate", methods=["POST"])
def deactivate_node():
    node["status"] = False
    return jsonify(node)


# Gets the active-services and their statuses
@app.route("/active-service", methods=["GET"])
def get_active_services():
    return jsonify(active_services), 200  # OK


# Change the active status of a service
@app.route("/active-service/toggle", methods=["POST"])
def set_active_service():
    title = request.args.get("title")  # An Ingress all
    # Toggle the status boolean value
    if active_services[title]["status"]:
        active_services[title]["status"] = False
    else:
        active_services[title]["status"] = True

    with open("active-services.json", "w") as f:
        json.dump(active_services, f)

    return jsonify(active_services[title]), 200  # OK


# Adds an active-service
@app.route("/active-service", methods=["POST"])
def add_active_service():
    if not request.json or "title" not in request.json:
        abort(400)  # Bad request

    title = request.json["title"]

    if title in active_services:
        abort(409)  # Conflict

    active_services[title] = {"status": False}

    with open("active-services.json", "w") as f:
        json.dump(active_services, f)

    return jsonify({"result": True}), 201  # Created


# Removes an active service from the list
@app.route("/active-service", methods=["DELETE"])
def delete_active_service():
    title = request.args.get("title")

    if not title:
        abort(400)  # Bad request

    if title not in active_services:
        abort(404)  # Not found

    del active_services[title]

    with open("active-services.json", "w") as f:
        json.dump(active_services, f)

    return jsonify({"result": True}), 200  # OK


# Gets all the avaliable services in the services file
@app.route("/services", methods=["GET"])
def get_services():
    return (config.config_directory / "services.json").read_text()


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=config.port)
