import json
from flask import Flask, abort, jsonify, request, send_file 

app = Flask(__name__)

with open('services.json', 'r') as f:
    services = json.load(f)
    
with open('active-services.json', 'r') as f:
    activeServices = json.load(f)

# ------ Single Node API ------ 
@app.route("/health-check")
def health_check():
    return {
            "health":"Good", "status":True}
    
@app.route('/active-services', methods=['GET'])
def get_services():
    return jsonify("/api/active-services.json")

# CRUD services

# ------ Cluster Node API ------ 

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
    
    