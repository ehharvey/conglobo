import json
import os
import socket
from flask import Flask, abort, jsonify, request, send_file, send_from_directory
import socket
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
    with open("services.json", "r") as f:
        data = json.load(f)
    return jsonify(data)


# Addds a new service to the services file
@app.route("/services", methods=["POST"])
def add_service():
    if not request.json or "title" not in request.json:
        abort(400)

    with open("active-services.json", "r") as f:
        services = json.load(f)

    new_service = {
        "title": request.json["title"],
        "description": request.json.get("description", ""),
    }
    services[new_service["title"]] = new_service

    with open("services.json", "w") as f:
        json.dump(services, f)

    return jsonify(services), 201


# Removes a service from the services file
@app.route("/services/<string:title>", methods=["DELETE"])
def delete_service(title):
    if title in services:
        services.pop(title)

        with open("services.json", "w") as f:
            json.dump(services, f)

        return jsonify({"result": True}), 200  # OK

    abort(404)


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=config.port)
