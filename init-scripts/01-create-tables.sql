-- Create table for biometric quality metrics
CREATE TABLE IF NOT EXISTS biometric_quality (
    id STRING PRIMARY KEY,
    photo_id STRING NOT NULL,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Biometric quality metrics
    frontal_pose DOUBLE,
    eyes_open DOUBLE,
    glasses_present BOOLEAN,
    smile_present BOOLEAN,
    blur_score DOUBLE,
    brightness_score DOUBLE,
    contrast_score DOUBLE,
    face_size_score DOUBLE,
    eye_distance DOUBLE,
    mouth_visibility DOUBLE,
    
    -- Additional metadata
    image_width INTEGER,
    image_height INTEGER,
    file_size INTEGER,
    processing_version STRING,
    
    -- Overall quality score (computed)
    overall_quality_score DOUBLE
) WITH (
    number_of_replicas = 0,
    "write.wait_for_active_shards" = 1
);

-- Create index for common queries
CREATE INDEX idx_frontal_pose ON biometric_quality (frontal_pose);
CREATE INDEX idx_overall_quality ON biometric_quality (overall_quality_score);
CREATE INDEX idx_timestamp ON biometric_quality (timestamp);

-- Insert some sample data for testing
INSERT INTO biometric_quality (
    id, photo_id, frontal_pose, eyes_open, glasses_present, 
    smile_present, blur_score, brightness_score, contrast_score,
    face_size_score, eye_distance, mouth_visibility,
    image_width, image_height, file_size, processing_version,
    overall_quality_score
) VALUES 
    ('sample1', 'photo001', 15.2, 0.95, false, true, 0.85, 0.75, 0.80, 0.90, 65.4, 0.88, 1920, 1080, 2048576, 'v1.0', 8.5),
    ('sample2', 'photo002', 8.7, 0.92, true, false, 0.78, 0.82, 0.85, 0.85, 62.1, 0.75, 1920, 1080, 1987654, 'v1.0', 7.8),
    ('sample3', 'photo003', 22.1, 0.88, false, false, 0.92, 0.70, 0.75, 0.95, 68.9, 0.92, 2560, 1440, 3145728, 'v1.0', 9.2),
    ('sample4', 'photo004', 5.3, 0.97, false, true, 0.88, 0.85, 0.90, 0.82, 59.7, 0.85, 1920, 1080, 2234567, 'v1.0', 8.9),
    ('sample5', 'photo005', 18.9, 0.85, true, false, 0.65, 0.60, 0.70, 0.88, 63.2, 0.70, 1920, 1080, 1876543, 'v1.0', 6.8);

-- Refresh table to make data available immediately
REFRESH TABLE biometric_quality;