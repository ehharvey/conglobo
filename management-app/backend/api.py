import json
from flask import Flask, jsonify, request, send_file 

app = Flask(__name__)

@app.route("/")
def hello_world():
    return "Hello World!"

@app.route("/health-check")
def health_check():
    return {
            "health":"Good", "status":True}
    
@app.route("/services", methods = ['GET', 'POST'])
def active_services():
    if request.method == 'GET':
        with open('api/services.json', 'r') as f:
            data = json.load(f)
            return jsonify(data)
        
    elif request.method == 'POST':

        on_services = request.form.get('on')
        off_services = request.form.get('off')
        if on_services or off_services:
            with open('api/services.json', 'r+') as f:
                data = json.load(f)
                services = data['services']
                if on_services:
                    on_services_list = [name.strip() for name in on_services.split(',')]
                    for name in on_services_list:
                        if name in services:
                            services[name]['active'] = True
                    on_message = f'Successfully turned on services: {", ".join(on_services_list)}.'
                else:
                    on_message = None
                if off_services:
                    off_services_list = [name.strip() for name in off_services.split(',')]
                    for name in off_services_list:
                        if name in services:
                            services[name]['active'] = False
                    off_message = f'Successfully turned off services: {", ".join(off_services_list)}.'
                else:
                    off_message = None
                f.seek(0)
                json.dump(data, f)
                f.truncate()
            messages = []
            if on_message:
                messages.append(on_message)
            if off_message:
                messages.append(off_message)
            if messages:
                message = ' '.join(messages)
            else:
                message = 'No services turned on or off.'
            return jsonify({'message': message})
        else:
            return jsonify({'error': 'Missing on or off parameter.'})



if __name__ == "__main__":
    app.run(debug=True,host='0.0.0.0')
    
    