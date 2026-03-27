from flask import Flask, request, jsonify
try:
    from dotenv import load_dotenv  # type: ignore
except ImportError:
    def load_dotenv():
        pass
import requests
import urllib3
import os

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

load_dotenv()

app = Flask(__name__)

AT_API_KEY  = os.getenv("AT_API_KEY")
AT_USERNAME = os.getenv("AT_USERNAME")
AT_URL      = os.getenv("AT_URL")

@app.route("/send-sms", methods=["POST"])
def send_sms():
    data = request.get_json()

    phone   = data.get("phone")
    message = data.get("message")

    if not phone or not message:
        return jsonify({"success": False, "error": "phone and message are required"}), 400

    phone = phone.strip().replace(" ", "")
    if phone.startswith("0"):
        phone = "+254" + phone[1:]
    elif phone.startswith("254"):
        phone = "+" + phone
    elif not phone.startswith("+"):
        phone = "+254" + phone

    print(f"Sending SMS to {phone}: {message}")

    response = requests.post(
        AT_URL,
        data={
            "username": AT_USERNAME,
            "to":       phone,
            "message":  message
        },
        headers={
            "apiKey": AT_API_KEY,
            "Accept": "application/json"
        },
        verify=False
    )

    print(f"AT Response [{response.status_code}]: {response.text}")

    if response.status_code == 201:
        return jsonify({"success": True, "message": "SMS sent successfully"}), 200
    else:
        return jsonify({"success": False, "error": response.text}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)