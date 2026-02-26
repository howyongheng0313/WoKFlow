# 🍳 WokFlow

**Where code meets cuisine.**

WokFlow is a culinary learning platform that brings the heat of professional kitchens to your screen. From mastering wok hei to perfecting Italian carbonara — learners enroll in chef-curated courses, watch step-by-step video chapters, take quizzes, and track their journey from novice to kitchen confident.

Built with ASP.NET Web Forms on .NET Framework 4.8, because sometimes the classics still slap.

![.NET Framework](https://img.shields.io/badge/.NET_Framework-4.8-purple?style=flat-square)
![Entity Framework](https://img.shields.io/badge/Entity_Framework-6.4.4-blue?style=flat-square)
![Tailwind CSS](https://img.shields.io/badge/Tailwind_CSS-CDN-38bdf8?style=flat-square)
![GSAP](https://img.shields.io/badge/GSAP-Animations-88ce02?style=flat-square)
![SQL Server](https://img.shields.io/badge/SQL_Server-LocalDB-red?style=flat-square)

---

## ✨ Features at a Glance

| Role | What they can do |
|------|-----------------|
| **Guest** | Browse courses, explore the platform |
| **Learner** | Enroll in courses, watch chapters, take quizzes, track progress |
| **Sharer** | Create courses with video chapters & quizzes, view analytics |
| **Admin** | Manage users, review sharer applications, moderate content, view platform analytics |

**Core functionality:**
- 🎥 Chapter-based video learning with progress tracking
- 📝 Per-chapter quizzes with pass/fail & retake support
- 📊 Sharer analytics dashboard (Chart.js powered)
- 🛡️ Content reporting & moderation workflow
- 🎓 Sharer registration with proof document uploads (50MB limit)
- 📈 Platform-wide analytics with monthly trend data

---

## 🏗️ Architecture

### Project Structure

```
WokFlow-ASPNET/
├── WokFlow-ASPNET.sln              # Solution file
│
└── WokFlow-ASPNET/                  # Main web project
    │
    ├── Models/                      # Entity models + DbContext
    │   ├── WokFlowContext.cs        #   EF6 DbContext (13 DbSets)
    │   ├── BasePage.cs              #   Page base class hierarchy
    │   ├── User.cs                  #   User, Course, Chapter,
    │   ├── Course.cs                #   Question, Answer, Enrollment,
    │   ├── ...                      #   QuizResult, Comment, etc.
    │   └── PlatformAnalytics.cs
    │
    ├── Pages/
    │   ├── Auth/                    # Login, Register, Logout
    │   ├── Learner/                 # Dashboard
    │   ├── Shared/                  # MyCourses, CourseDetail, UserProfile
    │   ├── Sharer/                  # CreateCourse, Analytics
    │   ├── Admin/                   # UserManagement, SharerRegistration,
    │   │                            # SharerRequests, ContentManagement,
    │   │                            # PlatformAnalytics
    │   └── Public/                  # About
    │
    ├── Controls/                    # Reusable ASCX components
    │   ├── LandingNavbar.ascx       #   Guest navigation
    │   ├── AuthenticatedNavbar.ascx #   Logged-in navigation
    │   ├── AdminNavbar.ascx         #   Admin navigation
    │   ├── Calendar.ascx            #   Date picker
    │   ├── CountrySelector.ascx     #   Country dropdown
    │   ├── StatsOverview.ascx       #   Stats cards
    │   ├── DashboardStats.ascx      #   Dashboard metrics
    │   └── ScoreModal.ascx          #   Quiz score popup
    │
    ├── Scripts/                     # Custom JavaScript
    │   ├── particles.js             #   Particle canvas animation
    │   ├── split-text.js            #   Text reveal animations
    │   ├── scroll-stack.js          #   Scroll-based stacking
    │   ├── click-spark.js           #   Click spark effects
    │   └── site.js                  #   General initialization
    │
    ├── Content/
    │   └── Site.css                 # Glass-morphism, glow effects
    │
    ├── Images/                      # Course thumbnails
    ├── Uploads/ProofDocuments/      # Sharer verification docs
    ├── App_Data/                    # WokFlow.mdf (SQL Server)
    │
    ├── Default.aspx                 # Landing page
    ├── Site.Master                  # Primary layout
    ├── MinimalSite.Master           # Stripped-down layout
    └── Web.config                   # App configuration
```

### Page Base Class Hierarchy

All pages inherit from a base class that handles session management and role-based access control:

```
BasePage
│   Session helpers: CurrentUserId, CurrentUserName,
│   CurrentUserRole, IsLoggedIn
│
├── AuthenticatedPage       → Redirects to Login if not logged in
│   ├── LearnerPage         → Blocks ADMINs from learner views
│   ├── SharerPage          → Requires SHARER role
│   └── AdminPage           → Requires ADMIN role
```

### Data Model (Entity Relationship)

```
Users ─────────────┬──────────────── Enrollments ──── Courses
  │                │                     │               │
  │                │              UserChapterProgress     │
  │                │                     │               │
  │           QuizResults           Chapters ────── Questions
  │                                                    │
  ├── Comments                                      Answers
  ├── SharerRegistrations
  └── ReportedContent                            Cuisines
                                                    │
                                              Courses (FK)

                                         PlatformAnalytics
                                         (standalone monthly snapshots)
```

### Frontend Stack

No build tools, no bundlers — just vibes and CDNs:

| Library | Purpose |
|---------|---------|
| **Tailwind CSS** | Utility-first styling |
| **GSAP + ScrollTrigger** | Smooth animations & scroll effects |
| **Lenis** | Smooth scrolling |
| **Chart.js** | Analytics charts |
| **Lucide Icons** | SVG icon set |
| **Google Fonts (Inter)** | Typography |

Custom visual effects include particle canvas animations, glass-morphism cards, ambient glow effects, and click-spark interactions.

---

## 🚀 Getting Started

### Prerequisites

- **Visual Studio 2017+** (2019 or 2022 recommended)
- **.NET Framework 4.8** Developer Pack
- **SQL Server LocalDB** (ships with Visual Studio)

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/WokFlow-ASPNET.git
   cd WokFlow-ASPNET
   ```

2. **Restore NuGet packages**
   ```
   nuget restore WokFlow-ASPNET.sln
   ```
   Or let Visual Studio auto-restore on first build.

3. **Set up the database**

   Open SQL Server Management Studio (SSMS) and run `Database_02.sql` against a fresh database named `WokFlow`. Then detach the `.mdf` and place it in the project's `App_Data/` folder.

   Alternatively, if `WokFlow.mdf` is already in `App_Data/`, it will auto-attach via the connection string:
   ```
   (LocalDb)\MSSQLLocalDB → AttachDbFilename=|DataDirectory|\WokFlow.mdf
   ```

4. **Run the application**
   - Open `WokFlow-ASPNET.sln` in Visual Studio
   - Press **F5** (debug) or **Ctrl+F5** (without debugger)
   - IIS Express will launch and open the landing page

### Seed Accounts

All seed accounts use the password: **`12345`**

| Username | Email | Role |
|----------|-------|------|
| Jiwoo | jiwoo@wokflow.com | ADMIN |
| Sarah Thompson | sarah.thompson@wokflow.com | ADMIN |
| Michael Chen | michael.chen@wokflow.com | ADMIN |
| How Yong Heng | how@gmail.com | SHARER |
| Randy Chee | randy@gmail.com | SHARER |
| Yuki Tanaka | yuki.tanaka@gmail.com | SHARER |
| Leong Yu Hang | leong@gmail.com | LEARNER |
| Kuek Zheng Yu | kuek@gmail.com | LEARNER |
| Sofia Nguyen | sofia.nguyen@gmail.com | LEARNER |
| David Kim | david.kim@gmail.com | LEARNER |

The seed data includes **4 cuisines**, **6 courses**, **27 chapters**, **54 quiz questions** (with 216 answers), **11 enrollments**, **34 chapter progress records**, **29 quiz results**, **11 comments**, and **10 reported content entries**.

---

## 🔧 Configuration

Key settings in `Web.config`:

| Setting | Value | Notes |
|---------|-------|-------|
| Session mode | `InProc` | In-memory, 30-min timeout |
| Max upload | `51200 KB` | ~50 MB (for proof documents) |
| Database | `(LocalDb)\MSSQLLocalDB` | Auto-attached from App_Data |
| Target framework | `.NET 4.8` | |

---

## 📂 Conventions

- **Namespace:** `WokFlow_ASPNET` (underscore matches project name)
- **User roles:** String constants — `"GUEST"`, `"LEARNER"`, `"SHARER"`, `"ADMIN"`
- **Course difficulty:** Integer `1–5`
- **Enrollment progress:** Integer `0–100` (percentage)
- **Authentication:** Pure session-based (`Session["UserId"]`, `Session["UserRole"]`, `Session["UserName"]`)
- **Passwords:** Hashed with BCrypt

---

## 🍜 What's on the Menu (Seed Courses)

| # | Course | Cuisine | Difficulty | Duration |
|---|--------|---------|:----------:|----------|
| 1 | Perfect Yangzhou Fried Rice Mastery | Chinese | ⭐⭐⭐ | 45 min |
| 2 | Classic Italian Carbonara | Western | ⭐⭐ | 50 min |
| 3 | Japanese Katsu Curry from Scratch | Japanese | ⭐⭐⭐⭐ | 70 min |
| 4 | Traditional Korean Bibimbap | Korean | ⭐⭐⭐ | 55 min |
| 5 | Dim Sum Essentials: Dumplings & Buns | Chinese | ⭐⭐⭐⭐⭐ | 90 min |
| 6 | Homemade Ramen Workshop | Japanese | ⭐⭐⭐⭐⭐ | 120 min |

---

## 📄 License

This project is developed for educational purposes.
