# CrateDB API endpoint (adjust if different)
CRATE_URL="http://localhost:4200/_sql"

# 1. CREATE TABLE - Initialize the biometric quality table
curl -X POST $CRATE_URL \
  -H "Content-Type: application/json" \
  -d '{
    "stmt": "CREATE TABLE IF NOT EXISTS biometric_quality (id STRING PRIMARY KEY, photo_id STRING NOT NULL, timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP, frontal_pose DOUBLE, eyes_open DOUBLE, glasses_present BOOLEAN, smile_present BOOLEAN, blur_score DOUBLE, brightness_score DOUBLE, contrast_score DOUBLE, face_size_score DOUBLE, eye_distance DOUBLE, mouth_visibility DOUBLE, image_width INTEGER, image_height INTEGER, file_size INTEGER, processing_version STRING, overall_quality_score DOUBLE) WITH (number_of_replicas = 0)"
  }'

# 2. CREATE INDEXES - For better query performance
curl -X POST $CRATE_URL \
  -H "Content-Type: application/json" \
  -d '{
    "stmt": "CREATE INDEX idx_frontal_pose ON biometric_quality (frontal_pose)"
  }'

curl -X POST $CRATE_URL \
  -H "Content-Type: application/json" \
  -d '{
    "stmt": "CREATE INDEX idx_overall_quality ON biometric_quality (overall_quality_score)"
  }'

curl -X POST $CRATE_URL \
  -H "Content-Type: application/json" \
  -d '{
    "stmt": "CREATE INDEX idx_timestamp ON biometric_quality (timestamp)"
  }'

# 3. INSERT SAMPLE DATA - Batch insert multiple records
curl -X POST $CRATE_URL \
  -H "Content-Type: application/json" \
  -d '{
    "stmt": "INSERT INTO biometric_quality (id, photo_id, frontal_pose, eyes_open, glasses_present, smile_present, blur_score, brightness_score, contrast_score, face_size_score, eye_distance, mouth_visibility, image_width, image_height, file_size, processing_version, overall_quality_score) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
    "bulk_args": [
      ["sample001", "photo_001", 15.2, 0.95, false, true, 0.85, 0.75, 0.80, 0.90, 65.4, 0.88, 1920, 1080, 2048576, "v1.0", 8.5],
      ["sample002", "photo_002", 8.7, 0.92, true, false, 0.78, 0.82, 0.85, 0.85, 62.1, 0.75, 1920, 1080, 1987654, "v1.0", 7.8],
      ["sample003", "photo_003", 22.1, 0.88, false, false, 0.92, 0.70, 0.75, 0.95, 68.9, 0.92, 2560, 1440, 3145728, "v1.0", 9.2],
      ["sample004", "photo_004", 5.3, 0.97, false, true, 0.88, 0.85, 0.90, 0.82, 59.7, 0.85, 1920, 1080, 2234567, "v1.0", 8.9],
      ["sample005", "photo_005", 18.9, 0.85, true, false, 0.65, 0.60, 0.70, 0.88, 63.2, 0.70, 1920, 1080, 1876543, "v1.0", 6.8],
      ["sample006", "photo_006", 12.4, 0.89, false, true, 0.82, 0.77, 0.83, 0.87, 64.5, 0.81, 1920, 1080, 2100000, "v1.0", 8.1],
      ["sample007", "photo_007", 25.6, 0.91, true, false, 0.79, 0.68, 0.72, 0.92, 67.8, 0.74, 2560, 1440, 3200000, "v1.0", 7.9],
      ["sample008", "photo_008", 3.2, 0.98, false, false, 0.91, 0.88, 0.92, 0.89, 61.3, 0.93, 1920, 1080, 2350000, "v1.0", 9.5],
      ["sample009", "photo_009", 19.7, 0.86, false, true, 0.76, 0.73, 0.78, 0.91, 66.7, 0.79, 1920, 1080, 2150000, "v1.0", 8.3],
      ["sample010", "photo_010", 11.8, 0.94, true, false, 0.84, 0.81, 0.86, 0.86, 63.9, 0.82, 1920, 1080, 2000000, "v1.0", 8.6],
      ["sample011", "photo_011", 16.3, 0.90, false, false, 0.87, 0.76, 0.81, 0.93, 65.8, 0.85, 2560, 1440, 3100000, "v1.0", 8.8],
      ["sample012", "photo_012", 7.9, 0.96, true, true, 0.80, 0.84, 0.87, 0.84, 60.2, 0.86, 1920, 1080, 2080000, "v1.0", 8.4],
      ["sample013", "photo_013", 28.4, 0.83, false, false, 0.73, 0.65, 0.69, 0.94, 69.1, 0.71, 2560, 1440, 3300000, "v1.0", 7.2],
      ["sample014", "photo_014", 4.1, 0.99, false, true, 0.93, 0.89, 0.94, 0.88, 58.9, 0.95, 1920, 1080, 2400000, "v1.0", 9.7],
      ["sample015", "photo_015", 13.6, 0.87, true, false, 0.81, 0.78, 0.84, 0.90, 64.1, 0.80, 1920, 1080, 2120000, "v1.0", 8.2]
    ]
  }'

# 4. REFRESH TABLE - Make data immediately available for queries
curl -X POST $CRATE_URL \
  -H "Content-Type: application/json" \
  -d '{
    "stmt": "REFRESH TABLE biometric_quality"
  }'

# 5. VERIFY DATA - Check if data was inserted successfully
echo "=== Verifying data insertion ==="
curl -X POST $CRATE_URL \
  -H "Content-Type: application/json" \
  -d '{
    "stmt": "SELECT COUNT(*) as total_records FROM biometric_quality"
  }'

# 6. SAMPLE QUERIES - Test different queries for your dashboard

echo -e "\n=== Records with frontal_pose > 12 ==="
curl -X POST $CRATE_URL \
  -H "Content-Type: application/json" \
  -d '{
    "stmt": "SELECT COUNT(*) as count FROM biometric_quality WHERE frontal_pose > 12"
  }'

echo -e "\n=== Quality score distribution ==="
curl -X POST $CRATE_URL \
  -H "Content-Type: application/json" \
  -d '{
    "stmt": "SELECT CASE WHEN overall_quality_score >= 9 THEN \"Excellent\" WHEN overall_quality_score >= 7 THEN \"Good\" WHEN overall_quality_score >= 5 THEN \"Fair\" ELSE \"Poor\" END as quality_level, COUNT(*) as count FROM biometric_quality GROUP BY quality_level ORDER BY MIN(overall_quality_score) DESC"
  }'

echo -e "\n=== Glasses vs No Glasses ==="
curl -X POST $CRATE_URL \
  -H "Content-Type: application/json" \
  -d '{
    "stmt": "SELECT CASE WHEN glasses_present THEN \"With Glasses\" ELSE \"No Glasses\" END as category, COUNT(*) as count FROM biometric_quality GROUP BY glasses_present"
  }'

echo -e "\n=== Average metrics by glasses presence ==="
curl -X POST $CRATE_URL \
  -H "Content-Type: application/json" \
  -d '{
    "stmt": "SELECT glasses_present, AVG(frontal_pose) as avg_frontal_pose, AVG(overall_quality_score) as avg_quality_score, COUNT(*) as count FROM biometric_quality GROUP BY glasses_present"
  }'

echo -e "\n=== Sample data preview ==="
curl -X POST $CRATE_URL \
  -H "Content-Type: application/json" \
  -d '{
    "stmt": "SELECT photo_id, frontal_pose, overall_quality_score, glasses_present, smile_present FROM biometric_quality ORDER BY overall_quality_score DESC LIMIT 5"
  }'