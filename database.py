import mysql.connector

DB_CONFIG = {
    "host": "127.0.0.1",
    "user": "root",
    "password": "",
    "database": "doctor_db",
    "port": 3307
}

def get_connection():
    return mysql.connector.connect(**DB_CONFIG)