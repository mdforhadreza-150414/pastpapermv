-- Past Paper MV Database Schema
-- MySQL/PostgreSQL compatible

-- ═══ USERS TABLE ═══
CREATE TABLE users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(120) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  whatsapp_number VARCHAR(20),
  school VARCHAR(100),
  grade VARCHAR(50),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  is_active BOOLEAN DEFAULT TRUE,
  INDEX idx_email (email)
);

-- ═══ SUBJECTS TABLE ═══
CREATE TABLE subjects (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) UNIQUE NOT NULL,
  icon VARCHAR(10),
  description TEXT,
  total_papers INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_name (name)
);

-- ═══ BOOKS/PAST PAPERS TABLE ═══
CREATE TABLE books (
  id INT PRIMARY KEY AUTO_INCREMENT,
  title VARCHAR(200) NOT NULL,
  subject_id INT NOT NULL,
  exam_level VARCHAR(50) NOT NULL,
  color_class VARCHAR(20),
  description TEXT,
  meta VARCHAR(255),
  price DECIMAL(10, 2) DEFAULT 0,
  years_covered VARCHAR(50),
  total_papers INT,
  includes_mark_schemes BOOLEAN DEFAULT TRUE,
  google_drive_url VARCHAR(500),
  preview_url VARCHAR(500),
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (subject_id) REFERENCES subjects(id),
  INDEX idx_level (exam_level),
  INDEX idx_subject (subject_id),
  INDEX idx_price (price)
);

-- ═══ PURCHASES TABLE ═══
CREATE TABLE purchases (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  book_id INT NOT NULL,
  amount DECIMAL(10, 2) NOT NULL,
  reference_code VARCHAR(50) UNIQUE,
  status ENUM('pending', 'confirmed', 'failed', 'refunded') DEFAULT 'pending',
  purchased_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  confirmed_at TIMESTAMP NULL,
  payment_proof_url VARCHAR(500),
  payment_method VARCHAR(50),
  notes TEXT,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (book_id) REFERENCES books(id),
  INDEX idx_user (user_id),
  INDEX idx_status (status),
  INDEX idx_reference (reference_code)
);

-- ═══ DOWNLOADS TABLE ═══
CREATE TABLE downloads (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  book_id INT NOT NULL,
  purchase_id INT,
  download_count INT DEFAULT 0,
  last_downloaded_at TIMESTAMP NULL,
  accessed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  ip_address VARCHAR(45),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (book_id) REFERENCES books(id),
  FOREIGN KEY (purchase_id) REFERENCES purchases(id),
  INDEX idx_user (user_id),
  INDEX idx_book (book_id)
);

-- ═══ PAYMENTS TABLE ═══
CREATE TABLE payments (
  id INT PRIMARY KEY AUTO_INCREMENT,
  purchase_id INT NOT NULL UNIQUE,
  user_id INT NOT NULL,
  amount DECIMAL(10, 2) NOT NULL,
  bml_account VARCHAR(50),
  bml_reference VARCHAR(100),
  payment_date TIMESTAMP,
  status ENUM('pending', 'verified', 'failed') DEFAULT 'pending',
  verified_by VARCHAR(100),
  verified_at TIMESTAMP NULL,
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (purchase_id) REFERENCES purchases(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_status (status),
  INDEX idx_user (user_id)
);

-- ═══ SESSIONS TABLE ═══
CREATE TABLE sessions (
  id VARCHAR(128) PRIMARY KEY,
  user_id INT NOT NULL,
  token VARCHAR(500),
  ip_address VARCHAR(45),
  user_agent VARCHAR(500),
  expires_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user (user_id),
  INDEX idx_expires (expires_at)
);

-- ═══ EXAM_LEVELS TABLE ═══
CREATE TABLE exam_levels (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(50) UNIQUE NOT NULL,
  description VARCHAR(255)
);

-- ═══ ACTIVITY_LOG TABLE ═══
CREATE TABLE activity_log (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT,
  action VARCHAR(100) NOT NULL,
  details TEXT,
  ip_address VARCHAR(45),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_user (user_id),
  INDEX idx_action (action),
  INDEX idx_date (created_at)
);

-- ═══ STATISTICS TABLE ═══
CREATE TABLE statistics (
  id INT PRIMARY KEY AUTO_INCREMENT,
  metric_name VARCHAR(100) NOT NULL,
  metric_value INT DEFAULT 0,
  recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY unique_metric (metric_name, DATE(recorded_at))
);

-- ═══ INSERT SAMPLE DATA ═══

-- Exam Levels
INSERT INTO exam_levels (name, description) VALUES
('O Level', 'Ordinary Level - Secondary Education'),
('A Level', 'Advanced Level - Higher Secondary Education'),
('SSC', 'Secondary School Certificate - Maldivian standard'),
('HSC', 'Higher Secondary Certificate - Maldivian standard');

-- Subjects
INSERT INTO subjects (name, icon, description, total_papers) VALUES
('Mathematics', '➕', 'Core mathematics subject covering algebra, geometry, calculus', 214),
('Physics', '⚛️', 'Physics past papers and solutions', 187),
('Chemistry', '🧪', 'Chemistry practical and theoretical papers', 163),
('Biology', '🧬', 'Biology and life sciences papers', 158),
('English Language', '📖', 'English language and literature papers', 201),
('Dhivehi', '🌿', 'Dhivehi language and literature', 142),
('Geography', '🌍', 'Geography and environmental studies', 119),
('History', '📜', 'History and social studies papers', 104),
('Economics', '💰', 'Economics and business economics', 137),
('Business Studies', '📊', 'Business and management studies', 122),
('ICT', '💻', 'Information and Communication Technology', 98),
('Islamic Studies', '☪️', 'Islamic education and studies', 89);

-- Books (Sample data matching HTML)
INSERT INTO books (title, subject_id, exam_level, color_class, description, meta, price, years_covered, total_papers, includes_mark_schemes, google_drive_url) VALUES
('O Level Mathematics 2019–2023', 1, 'O Level', 'bc-blue', 'Complete O Level Mathematics past papers', '5 years · 20 papers · Mark schemes included', 0.00, '2019-2023', 20, TRUE, 'https://drive.google.com/PLACEHOLDER_MATH_O'),
('A Level Physics 2020–2023', 2, 'A Level', 'bc-red', 'A Level Physics comprehensive collection', '4 years · 16 papers · Worked solutions', 45.00, '2020-2023', 16, TRUE, 'https://drive.google.com/PLACEHOLDER_PHYSICS_A'),
('Dhivehi Language SSC 2018–2023', 6, 'SSC', 'bc-green', 'SSC Dhivehi language complete pack', '6 years · 24 papers · Answer keys', 35.00, '2018-2023', 24, TRUE, 'https://drive.google.com/PLACEHOLDER_DHIVEHI_SSC'),
('English Language O Level 2021–2023', 5, 'O Level', 'bc-purple', 'O Level English language papers with model answers', '3 years · 12 papers · Examiner reports', 30.00, '2021-2023', 12, TRUE, 'https://drive.google.com/PLACEHOLDER_ENGLISH_O'),
('Chemistry A Level 2022–2023', 3, 'A Level', 'bc-brown', 'A Level Chemistry with detailed mark schemes', '2 years · 10 papers · Mark schemes', 40.00, '2022-2023', 10, TRUE, 'https://drive.google.com/PLACEHOLDER_CHEMISTRY_A'),
('Economics HSC 2019–2023', 9, 'HSC', 'bc-navy', 'HSC Economics complete past paper collection', '5 years · 15 papers · Model answers', 50.00, '2019-2023', 15, TRUE, 'https://drive.google.com/PLACEHOLDER_ECONOMICS_HSC'),
('Biology O Level Complete Pack', 4, 'O Level', 'bc-green', 'O Level Biology with full mark schemes', '4 years · 18 papers · Full mark schemes', 35.00, '2020-2023', 18, TRUE, 'https://drive.google.com/PLACEHOLDER_BIOLOGY_O'),
('ICT O Level 2020–2023', 11, 'O Level', 'bc-navy', 'O Level ICT practical and theory papers', '4 years · 16 papers', 0.00, '2020-2023', 16, TRUE, 'https://drive.google.com/PLACEHOLDER_ICT_O');
