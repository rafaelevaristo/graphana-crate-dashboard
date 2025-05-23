from flask import Flask, request, jsonify
import json
import uuid
from datetime import datetime
import requests
import time

app = Flask(__name__)

# CrateDB connection settings
CRATE_HOST = "cratedb"
CRATE_PORT = 4200
CRATE_URL = f"http://{CRATE_HOST}:{CRATE_PORT}/_sql"

def execute_sql(query, params=None):
    """Execute SQL query on CrateDB"""
    payload = {"stmt": query}
    if params:
        payload["args"] = params
    
    try:
        response = requests.post(CRATE_URL, json=payload)
        response.raise_for_status()
        return response.json()
    except Exception as e:
        print(f"Error executing SQL: {e}")
        return None

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({"status": "healthy", "timestamp": datetime.now().isoformat()})

@app.route('/ingest', methods=['POST'])
def ingest_biometric_data():
    """Ingest biometric quality data"""
    try:
        data = request.json
        
        # Generate unique ID if not provided
        record_id = data.get('id', str(uuid.uuid4()))
        
        # Prepare SQL insert
        query = """
        INSERT INTO biometric_quality (
            id, photo_id, frontal_pose, eyes_open, glasses_present,
            smile_present, blur_score, brightness_score, contrast_score,
            face_size_score, eye_distance, mouth_visibility,
            image_width, image_height, file_size, processing_version,
            overall_quality_score
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """
        
        params = [
            record_id,
            data.get('photo_id'),
            data.get('frontal_pose'),
            data.get('eyes_open'),
            data.get('glasses_present'),
            data.get('smile_present'),
            data.get('blur_score'),
            data.get('brightness_score'),
            data.get('contrast_score'),
            data.get('face_size_score'),
            data.get('eye_distance'),
            data.get('mouth_visibility'),
            data.get('image_width'),
            data.get('image_height'),
            data.get('file_size'),
            data.get('processing_version', 'v1.0'),
            data.get('overall_quality_score')
        ]
        
        result = execute_sql(query, params)
        
        if result:
            return jsonify({
                "status": "success", 
                "id": record_id,
                "message": "Data ingested successfully"
            }), 201
        else:
            return jsonify({"status": "error", "message": "Failed to insert data"}), 500
            
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 400

@app.route('/ingest/batch', methods=['POST'])
def ingest_batch_data():
    """Ingest multiple biometric quality records"""
    try:
        data = request.json
        records = data.get('records', [])
        
        if not records:
            return jsonify({"status": "error", "message": "No records provided"}), 400
        
        inserted_ids = []
        
        for record in records:
            record_id = record.get('id', str(uuid.uuid4()))
            
            query = """
            INSERT INTO biometric_quality (
                id, photo_id, frontal_pose, eyes_open, glasses_present,
                smile_present, blur_score, brightness_score, contrast_score,
                face_size_score, eye_distance, mouth_visibility,
                image_width, image_height, file_size, processing_version,
                overall_quality_score
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """
            
            params = [
                record_id,
                record.get('photo_id'),
                record.get('frontal_pose'),
                record.get('eyes_open'),
                record.get('glasses_present'),
                record.get('smile_present'),
                record.get('blur_score'),
                record.get('brightness_score'),
                record.get('contrast_score'),
                record.get('face_size_score'),
                record.get('eye_distance'),
                record.get('mouth_visibility'),
                record.get('image_width'),
                record.get('image_height'),
                record.get('file_size'),
                record.get('processing_version', 'v1.0'),
                record.get('overall_quality_score')
            ]
            
            result = execute_sql(query, params)
            if result:
                inserted_ids.append(record_id)
        
        return jsonify({
            "status": "success",
            "inserted_count": len(inserted_ids),
            "inserted_ids": inserted_ids
        }), 201
        
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 400

@app.route('/stats', methods=['GET'])
def get_stats():
    """Get basic statistics about the data"""
    try:
        # Get count of records with frontal_pose > 12
        query1 = "SELECT COUNT(*) as count FROM biometric_quality WHERE frontal_pose > 12"
        result1 = execute_sql(query1)
        
        # Get overall statistics
        query2 = """
        SELECT 
            COUNT(*) as total_records,
            AVG(frontal_pose) as avg_frontal_pose,
            AVG(overall_quality_score) as avg_quality_score,
            COUNT(*) FILTER (WHERE glasses_present = true) as with_glasses,
            COUNT(*) FILTER (WHERE smile_present = true) as with_smile
        FROM biometric_quality
        """
        result2 = execute_sql(query2)
        
        if result1 and result2:
            return jsonify({
                "frontal_pose_gt_12": result1['rows'][0][0],
                "total_records": result2['rows'][0][0],
                "avg_frontal_pose": result2['rows'][0][1],
                "avg_quality_score": result2['rows'][0][2],
                "records_with_glasses": result2['rows'][0][3],
                "records_with_smile": result2['rows'][0][4]
            })
        else:
            return jsonify({"status": "error", "message": "Failed to get statistics"}), 500
            
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

if __name__ == '__main__':
    # Wait for CrateDB to be ready
    print("Waiting for CrateDB to be ready...")
    time.sleep(10)
    
    app.run(host='0.0.0.0', port=5000, debug=True)