-- =====================================================
-- FULL STACK SKILL LEARNING ACADEMY MARKETPLACE
-- Database Schema (SQLite Compatible)
-- =====================================================

PRAGMA foreign_keys = ON;

-- =====================================================
-- USERS & AUTHENTICATION
-- =====================================================

CREATE TABLE IF NOT EXISTS users (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    uuid            TEXT    NOT NULL UNIQUE,
    email           TEXT    NOT NULL UNIQUE,
    username        TEXT    NOT NULL UNIQUE,
    password_hash   TEXT    NOT NULL,
    salt            TEXT    NOT NULL,
    full_name       TEXT    NOT NULL,
    avatar_url      TEXT,
    bio             TEXT,
    role            TEXT    NOT NULL DEFAULT 'student' CHECK(role IN ('student','instructor','admin')),
    is_verified     INTEGER NOT NULL DEFAULT 0,
    is_active       INTEGER NOT NULL DEFAULT 1,
    last_login_at   DATETIME,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS user_sessions (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id         INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    session_token   TEXT    NOT NULL UNIQUE,
    refresh_token   TEXT    UNIQUE,
    ip_address      TEXT,
    user_agent      TEXT,
    expires_at      DATETIME NOT NULL,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS email_verifications (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id         INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token           TEXT    NOT NULL UNIQUE,
    expires_at      DATETIME NOT NULL,
    used_at         DATETIME,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS password_resets (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id         INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token           TEXT    NOT NULL UNIQUE,
    expires_at      DATETIME NOT NULL,
    used_at         DATETIME,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS login_attempts (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    email           TEXT    NOT NULL,
    ip_address      TEXT,
    success         INTEGER NOT NULL DEFAULT 0,
    attempted_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- CATEGORIES & TAGS
-- =====================================================

CREATE TABLE IF NOT EXISTS categories (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    name            TEXT    NOT NULL UNIQUE,
    slug            TEXT    NOT NULL UNIQUE,
    description     TEXT,
    icon            TEXT,
    color           TEXT,
    parent_id       INTEGER REFERENCES categories(id),
    sort_order      INTEGER NOT NULL DEFAULT 0,
    is_active       INTEGER NOT NULL DEFAULT 1,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS tags (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    name            TEXT    NOT NULL UNIQUE,
    slug            TEXT    NOT NULL UNIQUE,
    usage_count     INTEGER NOT NULL DEFAULT 0,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- COURSES
-- =====================================================

CREATE TABLE IF NOT EXISTS courses (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,
    uuid                TEXT    NOT NULL UNIQUE,
    title               TEXT    NOT NULL,
    slug                TEXT    NOT NULL UNIQUE,
    subtitle            TEXT,
    description         TEXT,
    instructor_id       INTEGER NOT NULL REFERENCES users(id),
    category_id         INTEGER REFERENCES categories(id),
    thumbnail_url       TEXT,
    preview_video_url   TEXT,
    price               REAL    NOT NULL DEFAULT 0,
    discount_price      REAL,
    currency            TEXT    NOT NULL DEFAULT 'USD',
    level               TEXT    NOT NULL DEFAULT 'beginner' CHECK(level IN ('beginner','intermediate','advanced','all')),
    language            TEXT    NOT NULL DEFAULT 'English',
    duration_hours      REAL,
    total_lectures      INTEGER NOT NULL DEFAULT 0,
    total_students      INTEGER NOT NULL DEFAULT 0,
    avg_rating          REAL    NOT NULL DEFAULT 0,
    total_reviews       INTEGER NOT NULL DEFAULT 0,
    status              TEXT    NOT NULL DEFAULT 'draft' CHECK(status IN ('draft','review','published','archived')),
    is_featured         INTEGER NOT NULL DEFAULT 0,
    is_bestseller       INTEGER NOT NULL DEFAULT 0,
    requirements        TEXT,
    what_you_learn      TEXT,
    target_audience     TEXT,
    published_at        DATETIME,
    created_at          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS course_tags (
    course_id   INTEGER NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    tag_id      INTEGER NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    PRIMARY KEY (course_id, tag_id)
);

CREATE TABLE IF NOT EXISTS sections (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    course_id   INTEGER NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    title       TEXT    NOT NULL,
    description TEXT,
    sort_order  INTEGER NOT NULL DEFAULT 0,
    created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS lectures (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    section_id      INTEGER NOT NULL REFERENCES sections(id) ON DELETE CASCADE,
    course_id       INTEGER NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    title           TEXT    NOT NULL,
    description     TEXT,
    content_type    TEXT    NOT NULL DEFAULT 'video' CHECK(content_type IN ('video','article','quiz','assignment','live')),
    video_url       TEXT,
    article_content TEXT,
    duration_secs   INTEGER NOT NULL DEFAULT 0,
    sort_order      INTEGER NOT NULL DEFAULT 0,
    is_preview      INTEGER NOT NULL DEFAULT 0,
    is_published    INTEGER NOT NULL DEFAULT 1,
    resources       TEXT,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS quizzes (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    lecture_id  INTEGER NOT NULL REFERENCES lectures(id) ON DELETE CASCADE,
    title       TEXT    NOT NULL,
    pass_score  INTEGER NOT NULL DEFAULT 70,
    time_limit  INTEGER,
    created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS quiz_questions (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    quiz_id         INTEGER NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
    question        TEXT    NOT NULL,
    question_type   TEXT    NOT NULL DEFAULT 'mcq' CHECK(question_type IN ('mcq','true_false','short_answer')),
    options         TEXT,
    correct_answer  TEXT    NOT NULL,
    explanation     TEXT,
    points          INTEGER NOT NULL DEFAULT 1,
    sort_order      INTEGER NOT NULL DEFAULT 0
);

-- =====================================================
-- ENROLLMENTS & PROGRESS
-- =====================================================

CREATE TABLE IF NOT EXISTS enrollments (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id         INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    course_id       INTEGER NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    enrolled_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at    DATETIME,
    progress_pct    REAL    NOT NULL DEFAULT 0,
    last_accessed   DATETIME,
    certificate_url TEXT,
    UNIQUE(user_id, course_id)
);

CREATE TABLE IF NOT EXISTS lecture_progress (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    enrollment_id   INTEGER NOT NULL REFERENCES enrollments(id) ON DELETE CASCADE,
    lecture_id      INTEGER NOT NULL REFERENCES lectures(id) ON DELETE CASCADE,
    is_completed    INTEGER NOT NULL DEFAULT 0,
    watch_time_secs INTEGER NOT NULL DEFAULT 0,
    completed_at    DATETIME,
    UNIQUE(enrollment_id, lecture_id)
);

CREATE TABLE IF NOT EXISTS quiz_attempts (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id         INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    quiz_id         INTEGER NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
    score           REAL    NOT NULL,
    passed          INTEGER NOT NULL DEFAULT 0,
    answers         TEXT,
    attempted_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    time_taken_secs INTEGER
);

-- =====================================================
-- REVIEWS & RATINGS
-- =====================================================

CREATE TABLE IF NOT EXISTS reviews (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    course_id     INTEGER NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    user_id       INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    rating        INTEGER NOT NULL CHECK(rating BETWEEN 1 AND 5),
    title         TEXT,
    body          TEXT,
    is_verified   INTEGER NOT NULL DEFAULT 0,
    helpful_count INTEGER NOT NULL DEFAULT 0,
    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(course_id, user_id)
);

CREATE TABLE IF NOT EXISTS review_votes (
    user_id     INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    review_id   INTEGER NOT NULL REFERENCES reviews(id) ON DELETE CASCADE,
    is_helpful  INTEGER NOT NULL DEFAULT 1,
    PRIMARY KEY (user_id, review_id)
);

-- =====================================================
-- PAYMENTS & ORDERS
-- =====================================================

CREATE TABLE IF NOT EXISTS coupons (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    code            TEXT    NOT NULL UNIQUE,
    discount_type   TEXT    NOT NULL DEFAULT 'percent' CHECK(discount_type IN ('percent','fixed')),
    discount_value  REAL    NOT NULL,
    min_order       REAL    NOT NULL DEFAULT 0,
    max_uses        INTEGER,
    used_count      INTEGER NOT NULL DEFAULT 0,
    valid_from      DATETIME NOT NULL,
    valid_until     DATETIME,
    is_active       INTEGER NOT NULL DEFAULT 1,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS orders (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    uuid            TEXT    NOT NULL UNIQUE,
    user_id         INTEGER NOT NULL REFERENCES users(id),
    total_amount    REAL    NOT NULL,
    currency        TEXT    NOT NULL DEFAULT 'USD',
    status          TEXT    NOT NULL DEFAULT 'pending' CHECK(status IN ('pending','paid','failed','refunded')),
    payment_method  TEXT,
    payment_ref     TEXT    UNIQUE,
    coupon_id       INTEGER REFERENCES coupons(id),
    discount_amount REAL    NOT NULL DEFAULT 0,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    paid_at         DATETIME
);

CREATE TABLE IF NOT EXISTS order_items (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id    INTEGER NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    course_id   INTEGER NOT NULL REFERENCES courses(id),
    price       REAL    NOT NULL,
    created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- WISHLIST & CART
-- =====================================================

CREATE TABLE IF NOT EXISTS wishlists (
    user_id     INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    course_id   INTEGER NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    added_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, course_id)
);

CREATE TABLE IF NOT EXISTS cart_items (
    user_id     INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    course_id   INTEGER NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    added_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, course_id)
);

-- =====================================================
-- NOTIFICATIONS & MESSAGES
-- =====================================================

CREATE TABLE IF NOT EXISTS notifications (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id     INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type        TEXT    NOT NULL,
    title       TEXT    NOT NULL,
    message     TEXT    NOT NULL,
    link        TEXT,
    is_read     INTEGER NOT NULL DEFAULT 0,
    created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS messages (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    sender_id       INTEGER NOT NULL REFERENCES users(id),
    receiver_id     INTEGER NOT NULL REFERENCES users(id),
    course_id       INTEGER REFERENCES courses(id),
    subject         TEXT,
    body            TEXT    NOT NULL,
    is_read         INTEGER NOT NULL DEFAULT 0,
    parent_id       INTEGER REFERENCES messages(id),
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- CERTIFICATES
-- =====================================================

CREATE TABLE IF NOT EXISTS certificates (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    uuid            TEXT    NOT NULL UNIQUE,
    user_id         INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    course_id       INTEGER NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    issued_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    certificate_url TEXT,
    UNIQUE(user_id, course_id)
);

-- =====================================================
-- INDEXES
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_users_email         ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_username      ON users(username);
CREATE INDEX IF NOT EXISTS idx_sessions_token      ON user_sessions(session_token);
CREATE INDEX IF NOT EXISTS idx_sessions_user       ON user_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_courses_slug        ON courses(slug);
CREATE INDEX IF NOT EXISTS idx_courses_instructor  ON courses(instructor_id);
CREATE INDEX IF NOT EXISTS idx_courses_status      ON courses(status);
CREATE INDEX IF NOT EXISTS idx_enrollments_user    ON enrollments(user_id);
CREATE INDEX IF NOT EXISTS idx_reviews_course      ON reviews(course_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user  ON notifications(user_id, is_read);

-- =====================================================
-- SEED DATA
-- =====================================================

INSERT OR IGNORE INTO users (uuid,email,username,password_hash,salt,full_name,role,is_verified,bio)
VALUES
('uuid-admin-001','admin@skillacademy.com','admin','$2b$12$placeholder_admin_hash','salt001','Academy Admin','admin',1,'Platform administrator'),
('uuid-inst-001','instructor@skillacademy.com','johndoe_dev','$2b$12$placeholder_inst_hash','salt002','John Doe','instructor',1,'Senior full-stack developer with 10+ years experience.'),
('uuid-inst-002','sarah@skillacademy.com','sarah_ml','$2b$12$placeholder_inst2_hash','salt003','Sarah Chen','instructor',1,'ML Engineer at Google, PhD in Computer Science.'),
('uuid-std-001','student@skillacademy.com','janestudent','$2b$12$placeholder_std_hash','salt004','Jane Smith','student',1,NULL);

INSERT OR IGNORE INTO categories (name,slug,description,icon,color,sort_order) VALUES
('Web Development','web-development','HTML, CSS, JavaScript, React, Node.js','🌐','#3B82F6',1),
('Data Science','data-science','Python, ML, AI, Statistics','📊','#8B5CF6',2),
('Mobile Development','mobile-development','iOS, Android, Flutter, React Native','📱','#10B981',3),
('Cloud & DevOps','cloud-devops','AWS, Docker, Kubernetes, CI/CD','☁️','#F59E0B',4),
('Cybersecurity','cybersecurity','Ethical hacking, Penetration testing','🔒','#EF4444',5),
('UI/UX Design','ui-ux-design','Figma, Sketch, User Research','🎨','#EC4899',6),
('Database','database','SQL, NoSQL, PostgreSQL, MongoDB','🗄️','#6366F1',7),
('Blockchain','blockchain','Ethereum, Solidity, Web3, DeFi','⛓️','#14B8A6',8);

INSERT OR IGNORE INTO tags (name,slug) VALUES
('JavaScript','javascript'),('Python','python'),('React','react'),
('Node.js','nodejs'),('TypeScript','typescript'),('Docker','docker'),
('AWS','aws'),('Machine Learning','machine-learning'),('SQL','sql'),
('MongoDB','mongodb'),('REST API','rest-api'),('GraphQL','graphql'),
('Vue.js','vuejs'),('Angular','angular'),('Django','django'),
('FastAPI','fastapi'),('Kubernetes','kubernetes'),('Git','git');

INSERT OR IGNORE INTO courses (uuid,title,slug,subtitle,description,instructor_id,category_id,price,discount_price,level,duration_hours,total_lectures,total_students,avg_rating,total_reviews,status,is_featured,is_bestseller,what_you_learn,requirements)
VALUES
('c-uuid-001','Complete React & Node.js Bootcamp 2025','complete-react-nodejs-2025','Build production-ready full-stack apps','Master React 18, Node.js, Express, MongoDB, JWT Auth and deploy to AWS.',2,1,89.99,64.99,'beginner',42.5,186,12840,4.8,3421,'published',1,1,'["Build full-stack apps","Master React hooks","JWT authentication","Deploy to AWS"]','["Basic HTML/CSS","JavaScript fundamentals"]'),
('c-uuid-002','Machine Learning A-Z with Python','machine-learning-az','From theory to production ML pipelines','Comprehensive ML course covering supervised, unsupervised learning and deep neural networks.',3,2,94.99,69.99,'intermediate',38.0,165,9230,4.9,2187,'published',1,1,'["Build ML models","Neural networks","Data preprocessing","Model deployment"]','["Python basics","Linear algebra basics"]'),
('c-uuid-003','AWS Cloud Practitioner + Solutions Architect','aws-cloud-practitioner','Pass the AWS exam and build real cloud apps','Complete AWS prep course with hands-on labs. Covers EC2, S3, Lambda, RDS, VPC and more.',2,4,79.99,49.99,'beginner',28.0,134,7650,4.7,1893,'published',0,1,'["AWS core services","Cloud architecture","Serverless functions","Exam preparation"]','["Basic IT knowledge","No AWS experience needed"]'),
('c-uuid-004','Cybersecurity: Ethical Hacking Masterclass','cybersecurity-ethical-hacking','Become a certified ethical hacker','Learn penetration testing, vulnerability assessment, network security from zero.',3,5,99.99,74.99,'intermediate',35.0,148,5420,4.8,1245,'published',1,0,'["Penetration testing","Network security","Web app hacking","Report writing"]','["Basic networking","Linux command line"]'),
('c-uuid-005','Flutter & Dart: Complete Mobile Dev','flutter-dart-complete','Build iOS & Android apps with one codebase','Create beautiful cross-platform mobile apps with Flutter 3 and Dart.',2,3,74.99,54.99,'beginner',32.0,142,6780,4.7,1567,'published',0,1,'["Build mobile apps","Flutter widgets","State management","API integration"]','["OOP concepts","Any programming experience"]');

INSERT OR IGNORE INTO coupons (code,discount_type,discount_value,min_order,max_uses,used_count,valid_from,is_active)
VALUES
('LAUNCH50','percent',50,0,1000,245,'2025-01-01',1),
('STUDENT20','percent',20,29.99,5000,1230,'2025-01-01',1),
('FLAT10','fixed',10,39.99,NULL,890,'2025-01-01',1);

INSERT OR IGNORE INTO reviews (course_id,user_id,rating,title,body,is_verified)
VALUES
(1,4,5,'Absolutely incredible course!','John explains everything so clearly. I went from beginner to building full-stack apps in 6 weeks.',1),
(2,4,5,'Best ML course on the internet','Sarah makes complex topics very approachable. The projects are real-world and challenging.',1);

-- =====================================================
-- VIEWS
-- =====================================================

CREATE VIEW IF NOT EXISTS v_course_summary AS
SELECT c.id, c.uuid, c.title, c.slug, c.subtitle, c.price, c.discount_price,
       c.level, c.duration_hours, c.total_lectures, c.total_students,
       c.avg_rating, c.total_reviews, c.status, c.is_featured, c.is_bestseller,
       c.thumbnail_url, c.published_at,
       u.full_name AS instructor_name, u.avatar_url AS instructor_avatar,
       cat.name AS category_name, cat.slug AS category_slug, cat.icon AS category_icon
FROM courses c
JOIN users u ON u.id = c.instructor_id
LEFT JOIN categories cat ON cat.id = c.category_id;

CREATE VIEW IF NOT EXISTS v_user_stats AS
SELECT u.id, u.full_name, u.email, u.role,
       COUNT(DISTINCT e.id) AS enrolled_courses,
       COUNT(DISTINCT r.id) AS reviews_written,
       COUNT(DISTINCT cert.id) AS certificates_earned
FROM users u
LEFT JOIN enrollments e ON e.user_id = u.id
LEFT JOIN reviews r ON r.user_id = u.id
LEFT JOIN certificates cert ON cert.user_id = u.id
GROUP BY u.id;

-- END OF SCHEMA
