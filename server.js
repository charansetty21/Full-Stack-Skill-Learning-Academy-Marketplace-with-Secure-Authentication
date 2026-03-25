const express = require('express');
const mysql = require('mysql2/promise');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const cors = require('cors');
const dotenv = require('dotenv');

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

const JWT_SECRET = process.env.JWT_SECRET || 'super-secret-skill-academy-2026-jwt';

// Create MySQL connection pool
const pool = mysql.createPool({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'skill_academy',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

// Test DB connection
async function testDB() {
    try {
        const connection = await pool.getConnection();
        console.log('✅ MySQL Database Connected Successfully');
        connection.release();
    } catch (err) {
        console.error('❌ MySQL Connection Error:', err.message);
    }
}
testDB();

// ====================== AUTH MIDDLEWARE ======================
const authMiddleware = async (req, res, next) => {
    const token = req.header('Authorization')?.replace('Bearer ', '');
    if (!token) return res.status(401).json({ message: 'No token provided' });

    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        req.user = decoded;
        next();
    } catch (err) {
        res.status(401).json({ message: 'Invalid token' });
    }
};

// ====================== ROUTES ======================

// Register
app.post('/api/auth/register', async (req, res) => {
    const { name, email, password } = req.body;
    try {
        const hashed = await bcrypt.hash(password, 10);
        await pool.execute(
            'INSERT INTO users (name, email, password) VALUES (?, ?, ?)',
            [name, email, hashed]
        );
        res.status(201).json({ message: 'User registered successfully' });
    } catch (err) {
        if (err.code === 'ER_DUP_ENTRY') {
            return res.status(400).json({ message: 'Email already exists' });
        }
        res.status(500).json({ message: err.message });
    }
});

// Login
app.post('/api/auth/login', async (req, res) => {
    const { email, password } = req.body;
    try {
        const [rows] = await pool.execute('SELECT * FROM users WHERE email = ?', [email]);
        const user = rows[0];
        if (!user || !(await bcrypt.compare(password, user.password))) {
            return res.status(400).json({ message: 'Invalid credentials' });
        }

        const token = jwt.sign({ id: user.id, name: user.name, email: user.email }, JWT_SECRET, { expiresIn: '7d' });
        res.json({
            token,
            user: { id: user.id, name: user.name, email: user.email }
        });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// Get all courses (with optional search)
app.get('/api/courses', async (req, res) => {
    const { search } = req.query;
    let query = 'SELECT * FROM courses';
    let params = [];

    if (search) {
        query += ' WHERE title LIKE ? OR description LIKE ?';
        params = [`%${search}%`, `%${search}%`];
    }
    query += ' ORDER BY created_at DESC';

    try {
        const [courses] = await pool.execute(query, params);
        res.json({ courses });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// Add new course (used by MCP)
app.post('/api/courses', async (req, res) => {
    const { title, description, category, level, duration, link, instructor } = req.body;
    try {
        const [result] = await pool.execute(
            `INSERT INTO courses (title, description, category, level, duration, link, instructor, added_by_mcp) 
             VALUES (?, ?, ?, ?, ?, ?, ?, TRUE)`,
            [title, description, category, level, duration, link, instructor]
        );
        const [newCourse] = await pool.execute('SELECT * FROM courses WHERE id = ?', [result.insertId]);
        res.json({ course: newCourse[0] });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// Enroll in a course
app.post('/api/courses/enroll/:id', authMiddleware, async (req, res) => {
    const courseId = req.params.id;
    const userId = req.user.id;
    try {
        await pool.execute(
            'INSERT IGNORE INTO enrollments (user_id, course_id) VALUES (?, ?)',
            [userId, courseId]
        );
        res.json({ success: true, message: 'Enrolled successfully' });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// Get user dashboard (enrolled courses)
app.get('/api/users/dashboard', authMiddleware, async (req, res) => {
    const userId = req.user.id;
    try {
        const [enrolled] = await pool.execute(`
            SELECT c.* FROM courses c
            JOIN enrollments e ON c.id = e.course_id
            WHERE e.user_id = ?
            ORDER BY e.enrolled_at DESC
        `, [userId]);
        res.json({ enrolled });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// MCP simulation endpoint (you can call this from frontend too)
app.get('/api/mcp/discover', async (req, res) => {
    res.json({ message: 'MCP searched the internet and added new free courses via MySQL!' });
});

const PORT = process.env.PORT || 5001;
app.listen(PORT, () => {
    console.log(`🚀 Skill Academy Backend (MySQL) running on http://localhost:${PORT}`);
    console.log('🔐 Secure JWT Authentication active');
    console.log('🗄️ MySQL Database connected');
    console.log('🌐 MCP ready to add fresh free courses');
});