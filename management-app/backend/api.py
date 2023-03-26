import json
import os
import socket
from flask import Flask, abort, jsonify, request, send_file, send_from_directory
from app_management import AppManager, AppVolume, App, AppContainer
from conglobo_environment import CongloboEnvironment

hostname = socket.gethostname()
IPAddr = socket.gethostbyname(hostname)
Config = CongloboEnvironment()

port = 8000
app = Flask(__name__, static_folder="../frontend/build/web")

node = {"ip": IPAddr, "health": "Good", "status": True}

with open('config/active-apps.json', 'r') as f:
    active_apps = json.load(f)

app_manager = AppManager(Config.config_directory)

# Flutter Serving -----------------


@app.route('/')
def serve_flutter_build():
    return send_from_directory(app.static_folder, 'index.html')


@app.route('/<path:path>')
def send_report(path):
    return send_from_directory(app.static_folder, path)

#  API Routes - ---------------------


@app.route("/health-check")
def health_check():
    return jsonify(node)

# Node activation and deactivation


@app.route('/node/activate', methods=['POST'])
def activate_node():
    node['status'] = True
    return jsonify(node)


@app.route('/node/deactivate', methods=['POST'])
def deactivate_node():
    node['status'] = False
    return jsonify(node)

# Gets the active-apps and their statuses


@app.route('/active-apps', methods=['GET'])
def get_active_apps():
    apps = app_manager.get_apps()
    active_apps = {app.name: {"status": app.is_running()} for app in apps}
    return jsonify(active_apps), 200  # OK

# Change the active status of an app


@app.route("/active-apps/toggle", methods=["POST"])
def set_active_app():
    title = request.args.get("title")
    status = request.args.get("status")

    if not title or status not in ["true", "false"]:
        abort(400)  # Bad request

    # Get app by name from AppManager
    app = app_manager.get_app(title)
    if not app:
        abort(404)

    # Set app status based on request
    if status == "true":
        if not app_manager.get_app(title):
            app_manager.add_app(app)
    else:
        app_manager.delete_app(name=title)

    # Update active_apps dictionary and save to file
    apps = app_manager.get_apps()
    active_apps = {app.name: {"status": app.is_running()} for app in apps}
    with open('config/active-apps.json', 'w') as f:
        json.dump(active_apps, f)

    return jsonify(active_apps[title]), 200  # OK


if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0', port=port)
