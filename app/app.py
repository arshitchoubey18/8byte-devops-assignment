from flask import Flask, jsonify
import os
import psycopg2

app = Flask(__name__)

@app.route("/")
def home():
    return jsonify({"message": "8Byte.ai DevOps Assignment - OK", "version": "1.0"})

@app.route("/health")
def health():
    return jsonify({"status": "healthy"}), 200

@app.route("/db")
def db_check():
    try:
        conn = psycopg2.connect(
            host=os.getenv("DB_HOST"),
            dbname=os.getenv("DB_NAME", "appdb"),
            user=os.getenv("DB_USER"),
            password=os.getenv("DB_PASS")
        )
        cur = conn.cursor()
        cur.execute("SELECT 1")
        cur.close()
        conn.close()
        return jsonify({"db": "connected"})
    except Exception as e:
        return jsonify({"db": "error", "detail": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)