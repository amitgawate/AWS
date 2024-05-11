from flask import Flask

app = Flask(__name__)

@app.route('/hello', methods=['GET'])
def hello():
    return "Hello from ECS Cluster"

@app.route('/health', methods=['GET'])
def health():
    # This endpoint typically returns a simple HTTP 200 OK status,
    # indicating that the application is running correctly.
    return '', 200

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=80)
