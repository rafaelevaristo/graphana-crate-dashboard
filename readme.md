# Biometric Quality Dashboard POC

This Docker Compose setup provides a complete infrastructure for ingesting and visualizing biometric quality data using CrateDB and Grafana.

## 🏗️ Architecture

- **CrateDB**: Database for storing biometric quality metrics
- **Grafana**: Dashboard and visualization platform
- **Data Ingester**: Python Flask API for data ingestion

## 📁 Directory Structure

```
biometric-dashboard/
├── docker-compose.yml
├── init-scripts/
│   └── 01-create-tables.sql
├── grafana/
│   └── provisioning/
│       └── datasources/
│           └── datasource.yml
└── ingester/
    └── app.py
```

## 🚀 Quick Start

### 1. Start the services:

```bash
docker-compose up -d
```

### 2. Wait for services to be ready (about 30 seconds), then verify:

```bash
# Check if all services are running
docker-compose ps

# Check CrateDB logs
docker-compose logs cratedb

# Check Grafana logs
docker-compose logs grafana
```

## 🌐 Access Points

- **CrateDB Admin UI**: http://localhost:4200
- **Grafana Dashboard**: http://localhost:3000 (admin/admin123)
- **Data Ingestion API**: http://localhost:5000

## 📊 Using the System

### 1. View Sample Data
Navigate to CrateDB Admin UI (http://localhost:4200) and run:
```sql
SELECT * FROM biometric_quality;
```

### 2. Ingest New Data
```bash
# Single record
curl -X POST http://localhost:5000/ingest \
  -H "Content-Type: application/json" \
  -d '{
    "photo_id": "photo123",
    "frontal_pose": 15.5,
    "eyes_open": 0.92,
    "glasses_present": false,
    "smile_present": true,
    "blur_score": 0.85,
    "brightness_score": 0.78,
    "contrast_score": 0.82,
    "face_size_score": 0.90,
    "eye_distance": 65.2,
    "mouth_visibility": 0.88,
    "image_width": 1920,
    "image_height": 1080,
    "file_size": 2048576,
    "overall_quality_score": 8.7
  }'

# Batch records
curl -X POST http://localhost:5000/ingest/batch \
  -H "Content-Type: application/json" \
  -d '{
    "records": [
      {
        "photo_id": "batch001",
        "frontal_pose": 12.5,
        "eyes_open": 0.95,
        "glasses_present": true,
        "overall_quality_score": 8.2
      },
      {
        "photo_id": "batch002", 
        "frontal_pose": 18.2,
        "eyes_open": 0.88,
        "glasses_present": false,
        "overall_quality_score": 9.1
      }
    ]
  }'
```

### 3. Get Statistics
```bash
curl http://localhost:5000/stats
```

### 4. Create Grafana Dashboard

1. Go to http://localhost:3000 (admin/admin123)
2. Click "+" → "Dashboard" → "Add visualization"
3. Select "CrateDB" as data source
4. Use SQL queries like:

```sql
-- Count records where frontal_pose > 12
SELECT COUNT(*) as count 
FROM biometric_quality 
WHERE frontal_pose > 12;

-- Average quality scores over time
SELECT 
    DATE_TRUNC('hour', timestamp) as time,
    AVG(overall_quality_score) as avg_quality
FROM biometric_quality 
GROUP BY DATE_TRUNC('hour', timestamp)
ORDER BY time;

-- Distribution of frontal pose values
SELECT 
    CASE 
        WHEN frontal_pose < 10 THEN '0-10'
        WHEN frontal_pose < 20 THEN '10-20'
        ELSE '20+'
    END as pose_range,
    COUNT(*) as count
FROM biometric_quality
GROUP BY pose_range;
```

## 🔧 Useful SQL Queries

```sql
-- Records with good quality (frontal_pose > 12)
SELECT COUNT(*) FROM biometric_quality WHERE frontal_pose > 12;

-- Average metrics by glasses presence
SELECT 
    glasses_present,
    AVG(frontal_pose) as avg_frontal_pose,
    AVG(overall_quality_score) as avg_quality
FROM biometric_quality 
GROUP BY glasses_present;

-- Top 10 highest quality photos
SELECT photo_id, overall_quality_score 
FROM biometric_quality 
ORDER BY overall_quality_score DESC 
LIMIT 10;

-- Quality distribution
SELECT 
    CASE 
        WHEN overall_quality_score >= 9 THEN 'Excellent'
        WHEN overall_quality_score >= 7 THEN 'Good'
        WHEN overall_quality_score >= 5 THEN 'Fair'
        ELSE 'Poor'
    END as quality_category,
    COUNT(*) as count
FROM biometric_quality
GROUP BY quality_category;
```

## 🛠️ Troubleshooting

### Services not starting:
```bash
# Check logs
docker-compose logs

# Restart services
docker-compose down
docker-compose up -d
```

### CrateDB connection issues:
```bash
# Check if CrateDB is responding
curl http://localhost:4200/_cluster/health

# Connect directly to check tables
curl -X POST http://localhost:4200/_sql \
  -H "Content-Type: application/json" \
  -d '{"stmt": "SHOW TABLES"}'
```

### Reset everything:
```bash
docker-compose down -v
docker-compose up -d
```
