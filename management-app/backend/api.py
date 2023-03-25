import json
import os
import socket
from flask import Flask, abort, jsonify, request, send_file, send_from_directory

hostname = socket.gethostname()
IPAddr = socket.gethostbyname(hostname)

port = 8000
app = Flask(__name__, static_folder="../frontend/build/web")

node = {"ip": IPAddr, "health": "Good", "status": True}

with open('conglobo_environment/active-apps.json', 'r') as f:
    active_apps = json.load(f)

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
    return jsonify(active_apps), 200  # OK

# Change the active status of an app


@app.route('/active-apps/toggle', methods=['POST'])
def set_active_app():
    title = request.args.get('title')
    status = request.args.get('status')

    if not title or not status:
        abort(400)  # Bad request

    if title not in active_apps:
        abort(404)  # Not found

    # Toggle the status boolean value
    if active_apps[title]['status']:
        active_apps[title]['status'] = False
    else:
        active_apps[title]['status'] = True

    with open('conglobo_environment/active-apps.json', 'w') as f:
        json.dump(active_apps, f)

    return jsonify(active_apps[title]), 200  # OK


if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0', port=port)
