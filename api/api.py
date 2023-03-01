import json
import os
import socket
from flask import Flask, abort, jsonify, request, send_file 
import socket
hostname = socket.gethostname()
IPAddr = socket.gethostbyname(hostname)


app = Flask(__name__)

node = {"ip":IPAddr,"health":"Good", "status":True}

cwd = os.getcwd()

with open(cwd + '/api/services.json', 'r') as f:
    services = json.load(f)
    
with open(cwd + '/api/active-services.json', 'r') as f:
    active_services = json.load(f)

@app.route("/health-check")
def health_check():
    return jsonify(node)


@app.route('/node/activate', methods=['POST'])
def activate_node():
    node['status'] = True
    return jsonify(node)

@app.route('/node/deactivate', methods=['POST'])
def deactivate_node():
    node['status'] = False
    return jsonify(node)
    
# Gets the active-services and their statuses
@app.route('/active-service', methods=['GET'])
def get_active_services():
    return jsonify(active_services), 200  # OK

# Change the active status of a service
@app.route('/active-service/toggle', methods=['POST'])
def set_active_service():
    title = request.args.get('title')
    status = request.args.get('status')

    if not title or not status:
        abort(400)  # Bad request

    if title not in active_services:
        abort(404)  # Not found

    active_services[title]['status'] = status.lower() == 'true'

    with open(cwd + '/api/active-services.json', 'w') as f:
        json.dump(active_services, f)

    return jsonify(active_services[title]), 200  # OK

# Adds an active-service 
@app.route('/active-service', methods=['POST'])
def add_active_service():
    if not request.json or 'title' not in request.json:
        abort(400)  # Bad request

    title = request.json['title']

    if title in active_services:
        abort(409)  # Conflict

    active_services[title] = {'status': False}

    with open(cwd + '/api/active-services.json', 'w') as f:
        json.dump(active_services, f)

    return jsonify({'result': True}), 201  # Created

# Removes an active service from the list
@app.route('/active-service', methods=['DELETE'])
def delete_active_service():
    title = request.args.get('title')

    if not title:
        abort(400)  # Bad request

    if title not in active_services:
        abort(404)  # Not found

    del active_services[title]

    with open(cwd + '/api/active-services.json', 'w') as f:
        json.dump(active_services, f)

    return jsonify({'result': True}), 200  # OK


# Gets all the avaliable services in the services file
@app.route('/services', methods=['GET'])
def get_services():
    with open(cwd + '/api/services.json', 'r') as f:
        data = json.load(f)
    return jsonify(data)

# Addds a new service to the services file
@app.route('/services', methods=['POST'])
def add_service():
    if not request.json or 'title' not in request.json:
        abort(400)

    with open(cwd + '/api/services.json', 'r') as f:
        services = json.load(f)

    new_service = {
        'title': request.json['title'],
        'description': request.json.get('description', ''),
    }
    services[new_service['title']] = new_service

    with open(cwd + '/api/services.json', 'w') as f:
        json.dump(services, f)

    return jsonify(services), 201

# Removes a service from the services file
@app.route('/services/<string:title>', methods=['DELETE'])
def delete_service(title):
    if title in services:
        services.pop(title)

        with open(cwd + '/api/services.json', 'w') as f:
            json.dump(services, f)

        return jsonify({'result': True}), 200  # OK

    abort(404)

if __name__ == "__main__":
    app.run(debug=True,host='0.0.0.0')
    
    