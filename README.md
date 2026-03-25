# Full-Stack-Skill-Learning-Academy-Marketplace-with-Secure-Authentication
# SkillForge Academy – Full-Stack Skill Learning Marketplace

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Tech Stack](https://img.shields.io/badge/Stack-MERN%20%2F%20Next.js-green.svg)

A modern **full-stack online learning marketplace** where instructors can create and sell courses, and students can browse, purchase, and learn skills securely. Built with robust **secure authentication**, role-based access, payments, and an intuitive marketplace experience.

**Live Demo:** [Add your deployed link here]  
**Project Video:** [Add YouTube/demo link here]

---

## ✨ Features

### 🔐 Secure Authentication
- Email/Password login & registration with JWT
- Password hashing with bcrypt
- Forgot password + reset via email
- Google OAuth / Social login support (optional)
- Role-based access control (Student, Instructor, Admin)

### 🛒 Marketplace Experience
- Browse & search courses with filters (category, price, rating, level)
- Course details with preview videos, syllabus, reviews & ratings
- Wishlist & Cart functionality

### 📚 Course & Content Management
- Instructors can create, edit, and publish courses
- Multi-chapter/lecture structure with video, PDF, quizzes support
- Rich text editor for descriptions
- Progress tracking for enrolled students
- Completion certificates (optional)

### 💳 Secure Payments
- Integration with Razorpay / Stripe
- One-time purchase or subscription model
- Secure webhook handling

### 👤 User Dashboards
- **Student Dashboard**: Enrolled courses, progress, certificates
- **Instructor Dashboard**: Revenue analytics, course management, student insights
- **Admin Dashboard**: User management, course moderation, platform analytics

### Additional Highlights
- Responsive & modern UI (mobile-friendly)
- Dark/Light mode
- Real-time notifications (toasts)
- File uploads (videos, thumbnails) with Cloudinary
- Admin-only course/lecture moderation

---

## 🛠 Tech Stack

### Frontend
- **React.js** / **Next.js 13+** (App Router)
- Tailwind CSS + DaisyUI / Shadcn/ui
- Redux Toolkit / Zustand (state management)
- React Router / Next.js navigation

### Backend
- **Node.js** + **Express.js**
- **MongoDB** + Mongoose / Prisma
- JWT Authentication + bcrypt
- Multer + Cloudinary (file handling)
- Nodemailer (emails)

### Payments & Others
- Razorpay / Stripe
- Chart.js (analytics)
- React Hot Toast

**Alternative Modern Stack Option**: Next.js + TypeScript + Prisma + Clerk + Stripe + Mux + Tailwind

---

## 🚀 Getting Started

### Prerequisites
- Node.js (v18+)
- MongoDB (local or MongoDB Atlas)
- Cloudinary / UploadThing account
- Razorpay / Stripe keys

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/skillforge-academy.git
   cd skillforge-academy
