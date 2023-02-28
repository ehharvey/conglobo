import json
from flask import Flask, abort, jsonify, request, send_file 

app = Flask(__name__)

with open('services.json', 'r') as f:
    services = json.load(f)
    
with open('active-services.json', 'r') as f:
    active_services = json.load(f)

# ------ Single Node API ------ 


# CRUD services

# ------ Cluster Node API ------ 

@app.route("/health-check")
def health_check():
    return {
            "health":"Good", "status":True}
    
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

    if title not in active_services['active-services']:
        abort(404)  # Not found

    active_services['active-services'][title]['status'] = status

    with open('active-services.json', 'w') as f:
        json.dump(active_services, f)

    return jsonify(active_services['active-services'][title]), 200  # OK

# Adds an active-service 
@app.route('/active-service', methods=['POST'])
def add_active_service():
    if not request.json or 'title' not in request.json:
        abort(400)  # Bad request

    title = request.json['title']

    if title in active_services['active-services']:
        abort(409)  # Conflict

    active_services['active-services'][title] = {'status': False}

    with open('active-services.json', 'w') as f:
        json.dump(active_services, f)

    return jsonify({'result': True}), 201  # Created

# Removes an active service from the list
@app.route('/active-service', methods=['DELETE'])
def delete_active_service():
    title = request.args.get('title')

    if not title:
        abort(400)  # Bad request

    if title not in active_services['active-services']:
        abort(404)  # Not found

    del active_services['active-services'][title]

    with open('active-services.json', 'w') as f:
        json.dump(active_services, f)

    return jsonify({'result': True}), 200  # OK

# ------ Misc. API ------ 

# Gets all the avaliable services in the services file
@app.route('/services', methods=['GET'])
def get_services():
    return jsonify("/api/services.json")

# Addds a new service to the services file
@app.route('/services', methods=['POST'])
def add_service():
    if not request.json or 'title' not in request.json:
        abort(400) 

    new_service = {
        'title': request.json['title'],
        'description': request.json.get('description', ''),
    }

    services.append(new_service)

    with open('services.json', 'w') as f:
        json.dump(services, f)

    return jsonify(new_service), 201  

# Removes a service from the services file
@app.route('/services/<string:title>', methods=['DELETE'])
def delete_service(title):
    for i, service in enumerate(services):
        if service['title'] == title:
            services.pop(i)

            with open('services.json', 'w') as f:
                json.dump(services, f)

            return '', 204  

    abort(404) 

if __name__ == "__main__":
    app.run(debug=True,host='0.0.0.0')
    
    