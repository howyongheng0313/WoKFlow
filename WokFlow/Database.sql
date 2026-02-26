-- ============================================================
-- WokFlow Database Setup Script v2
-- Clean seed data with realistic users, courses and activity.
-- Run this against a fresh "WokFlow" database in SSMS before
-- detaching and adding the .mdf to Visual Studio's App_Data.
-- ============================================================

USE WokFlow;
GO

-- ============================================================
-- DDL: Create Tables (ordered to satisfy FK dependencies)
-- ============================================================

-- 1. Users
CREATE TABLE Users (
    UserId       INT            NOT NULL IDENTITY(1,1) PRIMARY KEY,
    Username     NVARCHAR(100)  NOT NULL,
    Email        NVARCHAR(255)  NOT NULL,
    PasswordHash NVARCHAR(255)  NOT NULL,
    Role         NVARCHAR(20)   NOT NULL,  -- GUEST, LEARNER, SHARER, ADMIN
    Status       NVARCHAR(20)   NOT NULL,  -- Active, Banned
    BirthDate    DATETIME       NULL,
    Country      NVARCHAR(100)  NULL,
    JoinedDate   DATETIME       NOT NULL,
    CreatedAt    DATETIME       NOT NULL,
    UpdatedAt    DATETIME       NOT NULL
);
GO

-- 2. Cuisines
CREATE TABLE Cuisines (
    CuisineId   INT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
    CuisineName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(500) NULL,
    CreatedAt   DATETIME      NOT NULL
);
GO

-- 3. Courses (Creator → Users: NO CASCADE)
CREATE TABLE Courses (
    CourseId    INT            NOT NULL IDENTITY(1,1) PRIMARY KEY,
    Title       NVARCHAR(200)  NOT NULL,
    Description NVARCHAR(2000) NULL,
    CuisineId   INT            NOT NULL,
    CreatorId   INT            NOT NULL,
    Duration    NVARCHAR(50)   NULL,
    Difficulty  INT            NOT NULL,
    ImageUrl    NVARCHAR(500)  NULL,
    Status      NVARCHAR(20)   NOT NULL,  -- Active, Deleted
    CreatedDate DATETIME       NOT NULL,
    CreatedAt   DATETIME       NOT NULL,
    UpdatedAt   DATETIME       NOT NULL,
    CONSTRAINT FK_Courses_Cuisines FOREIGN KEY (CuisineId) REFERENCES Cuisines(CuisineId),
    CONSTRAINT FK_Courses_Users    FOREIGN KEY (CreatorId)  REFERENCES Users(UserId)
    -- No CASCADE on CreatorId (configured via OnModelCreating)
);
GO

-- 4. Chapters
CREATE TABLE Chapters (
    ChapterId    INT            NOT NULL IDENTITY(1,1) PRIMARY KEY,
    CourseId     INT            NOT NULL,
    ChapterOrder INT            NOT NULL,
    Title        NVARCHAR(200)  NOT NULL,
    Description  NVARCHAR(1000) NULL,
    VideoUrl     NVARCHAR(500)  NULL,
    CreatedAt    DATETIME       NOT NULL,
    UpdatedAt    DATETIME       NOT NULL,
    CONSTRAINT FK_Chapters_Courses FOREIGN KEY (CourseId) REFERENCES Courses(CourseId)
);
GO

-- 5. Questions
CREATE TABLE Questions (
    QuestionId    INT            NOT NULL IDENTITY(1,1) PRIMARY KEY,
    ChapterId     INT            NOT NULL,
    QuestionText  NVARCHAR(1000) NOT NULL,
    QuestionOrder INT            NOT NULL,
    CreatedAt     DATETIME       NOT NULL,
    UpdatedAt     DATETIME       NOT NULL,
    CONSTRAINT FK_Questions_Chapters FOREIGN KEY (ChapterId) REFERENCES Chapters(ChapterId)
);
GO

-- 6. Answers
CREATE TABLE Answers (
    AnswerId    INT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
    QuestionId  INT           NOT NULL,
    AnswerText  NVARCHAR(500) NOT NULL,
    IsCorrect   BIT           NOT NULL,
    AnswerOrder INT           NOT NULL,
    CreatedAt   DATETIME      NOT NULL,
    CONSTRAINT FK_Answers_Questions FOREIGN KEY (QuestionId) REFERENCES Questions(QuestionId)
);
GO

-- 7. Enrollments
CREATE TABLE Enrollments (
    EnrollmentId   INT          NOT NULL IDENTITY(1,1) PRIMARY KEY,
    UserId         INT          NOT NULL,
    CourseId       INT          NOT NULL,
    EnrollmentDate DATETIME     NOT NULL,
    Progress       INT          NOT NULL,
    Status         NVARCHAR(20) NOT NULL,  -- In Progress, Completed
    CreatedAt      DATETIME     NOT NULL,
    UpdatedAt      DATETIME     NOT NULL,
    CONSTRAINT FK_Enrollments_Users   FOREIGN KEY (UserId)   REFERENCES Users(UserId),
    CONSTRAINT FK_Enrollments_Courses FOREIGN KEY (CourseId) REFERENCES Courses(CourseId)
);
GO

-- 8. UserChapterProgress (UserId NO CASCADE, EnrollmentId NO CASCADE)
CREATE TABLE UserChapterProgress (
    ProgressId     INT      NOT NULL IDENTITY(1,1) PRIMARY KEY,
    UserId         INT      NOT NULL,
    EnrollmentId   INT      NOT NULL,
    ChapterId      INT      NOT NULL,
    IsCompleted    BIT      NOT NULL,
    CompletedDate  DATETIME NULL,
    CreatedAt      DATETIME NOT NULL,
    UpdatedAt      DATETIME NOT NULL,
    CONSTRAINT FK_UCP_Users       FOREIGN KEY (UserId)       REFERENCES Users(UserId),
    CONSTRAINT FK_UCP_Enrollments FOREIGN KEY (EnrollmentId) REFERENCES Enrollments(EnrollmentId),
    CONSTRAINT FK_UCP_Chapters    FOREIGN KEY (ChapterId)    REFERENCES Chapters(ChapterId)
    -- UserId and EnrollmentId have no cascade (configured via OnModelCreating)
);
GO

-- 9. QuizResults (UserId NO CASCADE)
CREATE TABLE QuizResults (
    ResultId      INT          NOT NULL IDENTITY(1,1) PRIMARY KEY,
    UserId        INT          NOT NULL,
    ChapterId     INT          NOT NULL,
    Score         INT          NOT NULL,
    Status        NVARCHAR(20) NOT NULL,  -- Passed, Failed
    CompletedDate DATETIME     NOT NULL,
    CreatedAt     DATETIME     NOT NULL,
    CONSTRAINT FK_QuizResults_Users    FOREIGN KEY (UserId)    REFERENCES Users(UserId),
    CONSTRAINT FK_QuizResults_Chapters FOREIGN KEY (ChapterId) REFERENCES Chapters(ChapterId)
    -- UserId has no cascade (configured via OnModelCreating)
);
GO

-- 10. Comments (UserId NO CASCADE)
CREATE TABLE Comments (
    CommentId   INT            NOT NULL IDENTITY(1,1) PRIMARY KEY,
    CourseId    INT            NOT NULL,
    UserId      INT            NOT NULL,
    CommentText NVARCHAR(2000) NOT NULL,
    Rating      INT            NOT NULL,  -- 1-5
    CreatedDate DATETIME       NOT NULL,
    CreatedAt   DATETIME       NOT NULL,
    UpdatedAt   DATETIME       NOT NULL,
    CONSTRAINT FK_Comments_Courses FOREIGN KEY (CourseId) REFERENCES Courses(CourseId),
    CONSTRAINT FK_Comments_Users   FOREIGN KEY (UserId)   REFERENCES Users(UserId)
    -- UserId has no cascade (configured via OnModelCreating)
);
GO

-- 11. SharerRegistrations
CREATE TABLE SharerRegistrations (
    RegistrationId INT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
    UserId         INT           NOT NULL,
    RequestDate    DATETIME      NOT NULL,
    ProofDocument  NVARCHAR(500) NULL,
    Status         NVARCHAR(20)  NOT NULL,  -- Pending, Accepted, Rejected
    ReviewedBy     INT           NULL,
    ReviewedDate   DATETIME      NULL,
    CreatedAt      DATETIME      NOT NULL,
    UpdatedAt      DATETIME      NOT NULL,
    CONSTRAINT FK_SharerRegistrations_Users FOREIGN KEY (UserId) REFERENCES Users(UserId)
);
GO

-- 13. ReportedContent (CourseId NO CASCADE, ReporterId NO CASCADE)
CREATE TABLE ReportedContent (
    ReportId     INT            NOT NULL IDENTITY(1,1) PRIMARY KEY,
    CourseId     INT            NOT NULL,
    ReporterId   INT            NOT NULL,
    Reason       NVARCHAR(1000) NOT NULL,
    ReportDate   DATETIME       NOT NULL,
    Status       NVARCHAR(20)   NOT NULL,  -- Pending, Ignored, Banned
    ReviewedBy   INT            NULL,
    ReviewedDate DATETIME       NULL,
    CreatedAt    DATETIME       NOT NULL,
    UpdatedAt    DATETIME       NOT NULL,
    CONSTRAINT FK_ReportedContent_Courses FOREIGN KEY (CourseId)   REFERENCES Courses(CourseId),
    CONSTRAINT FK_ReportedContent_Users   FOREIGN KEY (ReporterId) REFERENCES Users(UserId)
    -- Both FKs have no cascade (configured via OnModelCreating)
);
GO

-- 14. PlatformAnalytics
CREATE TABLE PlatformAnalytics (
    AnalyticsId        INT      NOT NULL IDENTITY(1,1) PRIMARY KEY,
    RecordDate         DATETIME NOT NULL,
    NewUsersCount      INT      NOT NULL,
    TotalUsersCount    INT      NOT NULL,
    ActiveCoursesCount INT      NOT NULL,
    TotalCoursesCount  INT      NOT NULL,
    CreatedAt          DATETIME NOT NULL
);
GO

-- ============================================================
-- DML: Seed Data
-- ============================================================

-- ────────────────────────────────────────────────────────────
-- 1. Cuisines (4 records)
-- ────────────────────────────────────────────────────────────
SET IDENTITY_INSERT Cuisines ON;
INSERT INTO Cuisines (CuisineId, CuisineName, Description, CreatedAt) VALUES
(1, N'Chinese',  N'Chinese cuisine featuring stir-frying, steaming, braising and a rich variety of regional cooking styles.',         '2024-01-01 00:00:00'),
(2, N'Western',  N'Western cuisine encompassing Italian, French, British and other European culinary traditions.',                    '2024-01-01 00:00:00'),
(3, N'Japanese', N'Japanese cuisine known for its emphasis on fresh, seasonal ingredients, umami flavours and elegant presentation.', '2024-01-01 00:00:00'),
(4, N'Korean',   N'Korean cuisine celebrated for its bold spicy flavours, fermented ingredients and communal dining culture.',        '2024-01-01 00:00:00');
SET IDENTITY_INSERT Cuisines OFF;
GO

-- ────────────────────────────────────────────────────────────
-- 2. Users (10 records: 3 ADMIN, 3 SHARER, 4 LEARNER)
-- ────────────────────────────────────────────────────────────
SET IDENTITY_INSERT Users ON;
INSERT INTO Users (UserId, Username, Email, PasswordHash, Role, Status, BirthDate, Country, JoinedDate, CreatedAt, UpdatedAt) VALUES
-- Admins (all passwords: 12345, hashed with BCrypt)
( 1, N'Jiwoo',          N'jiwoo@wokflow.com',          N'$2b$11$EwF2.xLtmFjS40sFqG8vEuHG67l0KFMO2KNopC.t6WXCXloMbYsKO', N'ADMIN',   N'Active', '1975-03-22', N'United States', '2024-01-01', '2024-01-01 08:00:00', '2024-01-01 08:00:00'),
( 2, N'Sarah Thompson', N'sarah.thompson@wokflow.com', N'$2b$11$7EfoK1fRHvoxzs.6dxstvODrFSBZIfPYT3mK4hfJ1qOrRtBXBVovi', N'ADMIN',   N'Active', '1980-07-15', N'United Kingdom','2024-01-01', '2024-01-01 08:00:00', '2024-01-01 08:00:00'),
( 3, N'Michael Chen',   N'michael.chen@wokflow.com',   N'$2b$11$.LnjIpv5e2mTN7ioxsJUZewCX1B9BTLGkd6XciZ9Q7t0supJFTisS', N'ADMIN',   N'Active', '1978-11-30', N'Singapore',     '2024-01-01', '2024-01-01 08:00:00', '2024-01-01 08:00:00'),
-- Sharers
( 4, N'How Yong Heng',  N'how@gmail.com',              N'$2b$11$4SWss2EkQbMDNLFZbg02/O5qEuGD92.vqyIRibfiOuxSDDygbjDvG', N'SHARER',  N'Active', '1985-04-12', N'Malaysia',      '2024-06-01', '2024-06-01 09:00:00', '2024-06-01 09:00:00'),
( 5, N'Randy Chee',     N'randy@gmail.com',            N'$2b$11$CNnAx.U8d4wuQsZR6jric.rfPSFOT9gs.CT7HCueUqIvC63rXwwPq', N'SHARER',  N'Active', '1982-09-08', N'Malaysia',      '2024-04-15', '2024-04-15 10:30:00', '2024-04-15 10:30:00'),
( 6, N'Yuki Tanaka',    N'yuki.tanaka@gmail.com',      N'$2b$11$1j5jhMUHWOk.5amNxjYboe8x2GGEZx9b4PoXmw/5EA4dR/w6O7uRm', N'SHARER',  N'Active', '1988-02-20', N'Japan',         '2024-06-20', '2024-06-20 11:00:00', '2024-06-20 11:00:00'),
-- Learners
( 7, N'Leong Yu Hang',  N'leong@gmail.com',            N'$2b$11$BX0g/ZaHYzzgp9hgVSifCOTZYKr5RIbRbOs3Y0T3hjpVHq3SYmvjC', N'LEARNER', N'Active', '1998-06-14', N'Malaysia',      '2025-01-10', '2025-01-10 14:00:00', '2025-01-10 14:00:00'),
( 8, N'Kuek Zheng Yu',  N'kuek@gmail.com',             N'$2b$11$4JB3xzDk4YwasdQbszOpee5ZV7vlBSLSR80w8hE14mcMrHmQRU2fG', N'LEARNER', N'Active', '1995-11-03', N'Malaysia',      '2025-01-15', '2025-01-15 09:30:00', '2025-01-15 09:30:00'),
( 9, N'Sofia Nguyen',   N'sofia.nguyen@gmail.com',     N'$2b$11$sC1TTYrO15FXFRvmwnfGaeFkYEfKdBarKef5NofpTGDH.C3XxlGXW', N'LEARNER', N'Active', '2000-03-28', N'Vietnam',       '2025-02-18', '2025-02-18 16:00:00', '2025-02-18 16:00:00'),
(10, N'David Kim',      N'david.kim@gmail.com',        N'$2b$11$/vplCDjUdwOJqk6vHHVg9.Iftk8mpyAihbfzyW/0UhuNU3Qv5UFSy', N'LEARNER', N'Active', '1997-08-17', N'South Korea',   '2025-01-22', '2025-01-22 13:00:00', '2025-01-22 13:00:00');
SET IDENTITY_INSERT Users OFF;
GO

-- ────────────────────────────────────────────────────────────
-- 3. Courses (6 records)
-- ────────────────────────────────────────────────────────────
SET IDENTITY_INSERT Courses ON;
INSERT INTO Courses (CourseId, Title, Description, CuisineId, CreatorId, Duration, Difficulty, ImageUrl, Status, CreatedDate, CreatedAt, UpdatedAt) VALUES
(1, N'Perfect Yangzhou Fried Rice Mastery',
   N'Master the art of creating authentic Yangzhou fried rice with perfectly separated grains, vibrant colours and restaurant-quality wok hei. Learn ingredient selection, day-old rice preparation and the high-heat techniques that define this Jiangsu classic.',
   1, 4, N'45 mins', 3, N'/Images/courses/yangzhou-fried-rice.jpg', N'Active', '2024-10-15', '2024-10-15 09:00:00', '2024-10-15 09:00:00'),

(2, N'Classic Italian Carbonara',
   N'Create the perfect Roman-style carbonara with a silky egg-and-cheese sauce, crispy guanciale and al dente spaghetti. No cream required — just authentic technique, quality ingredients and the secrets that Italian nonnas have kept for generations.',
   2, 5, N'50 mins', 2, N'/Images/courses/carbonara.jpg',           N'Active', '2024-11-20', '2024-11-20 10:15:00', '2024-11-20 10:15:00'),

(3, N'Japanese Katsu Curry from Scratch',
   N'Go beyond the curry block: make authentic Japanese curry roux from scratch, achieve a perfectly breaded and fried tonkatsu, and cook fluffy short-grain rice. A comprehensive guide from knife skills to plating with traditional accompaniments.',
   3, 6, N'70 mins', 4, N'/Images/courses/katsu-curry.jpg',         N'Active', '2024-10-30', '2024-10-30 13:20:00', '2024-10-30 13:20:00'),

(4, N'Traditional Korean Bibimbap',
   N'Master the harmony of Korean bibimbap — seasoned namul vegetables, marinated beef, a runny fried egg and homemade gochujang sauce served over crispy rice in a sizzling stone bowl. Learn both the dolsot and regular bowl methods.',
   4, 4, N'55 mins', 3, N'/Images/courses/bibimbap.jpg',            N'Active', '2024-12-05', '2024-12-05 15:40:00', '2024-12-05 15:40:00'),

(5, N'Dim Sum Essentials: Dumplings & Buns',
   N'Create restaurant-quality dim sum at home. This course covers har gow and siu mai wrappers from scratch, traditional fillings, pleating techniques, steaming methods and the classic dipping sauces. Patience and practice transform beginners into confident dim sum makers.',
   1, 4, N'90 mins', 5, N'/Images/courses/dim-sum.jpg',             N'Active', '2025-01-08', '2025-01-08 08:30:00', '2025-01-08 08:30:00'),

(6, N'Homemade Ramen Workshop',
   N'Build your ramen completely from scratch: a rich 12-hour tonkotsu broth, fresh alkaline noodles, melt-in-the-mouth chashu pork, marinated soft-boiled eggs and balanced tare seasoning. A challenging but deeply rewarding journey into ramen mastery.',
   3, 6, N'120 mins', 5, N'/Images/courses/ramen.jpg',              N'Active', '2024-11-12', '2024-11-12 09:45:00', '2024-11-12 09:45:00');
SET IDENTITY_INSERT Courses OFF;
GO

-- ────────────────────────────────────────────────────────────
-- 4. Chapters (27 records)
--    Course 1: Ch 1–4   | Course 2: Ch 5–7   | Course 3: Ch 8–12
--    Course 4: Ch 13–16 | Course 5: Ch 17–21  | Course 6: Ch 22–27
-- ────────────────────────────────────────────────────────────
SET IDENTITY_INSERT Chapters ON;
INSERT INTO Chapters (ChapterId, CourseId, ChapterOrder, Title, Description, VideoUrl, CreatedAt, UpdatedAt) VALUES
-- Course 1: Yangzhou Fried Rice (4 chapters)
( 1, 1, 1, N'Introduction to Yangzhou Fried Rice',   N'Explore the history and regional significance of Yangzhou fried rice and what sets it apart from other fried rice dishes.',          N'/Videos/chapters/yfr_ch01.mp4', '2024-10-15 09:00:00', '2024-10-15 09:00:00'),
( 2, 1, 2, N'Ingredient Selection and Preparation',  N'Learn to pick the right rice, proteins and vegetables, and why day-old rice is the non-negotiable foundation of great fried rice.',  N'/Videos/chapters/yfr_ch02.mp4', '2024-10-15 09:00:00', '2024-10-15 09:00:00'),
( 3, 1, 3, N'Wok Techniques and Cooking',            N'Master high-heat wok control, the toss-and-fold motion and achieving authentic wok hei smokiness at home.',                        N'/Videos/chapters/yfr_ch03.mp4', '2024-10-15 09:00:00', '2024-10-15 09:00:00'),
( 4, 1, 4, N'Plating and Final Touches',             N'Finish your dish with traditional garnishes and learn the bowl-mould technique for restaurant-style dome presentation.',            N'/Videos/chapters/yfr_ch04.mp4', '2024-10-15 09:00:00', '2024-10-15 09:00:00'),

-- Course 2: Italian Carbonara (3 chapters)
( 5, 2, 1, N'Carbonara Fundamentals',                N'Understand the Roman origin of carbonara, the role of each ingredient and the most common mistakes that ruin this classic dish.',   N'/Videos/chapters/carb_ch01.mp4', '2024-11-20 10:15:00', '2024-11-20 10:15:00'),
( 6, 2, 2, N'Cooking Pasta and Guanciale',           N'Cook spaghetti to perfect al dente and render guanciale until golden and crispy while retaining its fat for flavour.',             N'/Videos/chapters/carb_ch02.mp4', '2024-11-20 10:15:00', '2024-11-20 10:15:00'),
( 7, 2, 3, N'Creating the Creamy Egg Sauce',         N'Whisk the egg-and-Pecorino emulsion, combine it off heat and use pasta water to achieve a glossy, cream-free sauce.',             N'/Videos/chapters/carb_ch03.mp4', '2024-11-20 10:15:00', '2024-11-20 10:15:00'),

-- Course 3: Katsu Curry (5 chapters)
( 8, 3, 1, N'Japanese Curry Basics',                 N'Trace Japanese curry from its Indian roots through British naval influence to the mild, sweet-savoury dish beloved across Japan.',  N'/Videos/chapters/kc_ch01.mp4', '2024-10-30 13:20:00', '2024-10-30 13:20:00'),
( 9, 3, 2, N'Making Curry Roux from Scratch',        N'Toast and blend your own spice mix, cook a butter-flour roux and build layered curry flavour without relying on commercial blocks.', N'/Videos/chapters/kc_ch02.mp4', '2024-10-30 13:20:00', '2024-10-30 13:20:00'),
(10, 3, 3, N'Preparing the Perfect Tonkatsu',        N'Pound, season and coat the pork cutlet in the classic flour-egg-panko sequence, then fry it to a shatteringly crispy finish.',     N'/Videos/chapters/kc_ch03.mp4', '2024-10-30 13:20:00', '2024-10-30 13:20:00'),
(11, 3, 4, N'Cooking the Curry Sauce',               N'Sweat the vegetables, add stock and simmer until tender, then dissolve your roux for a rich, glossy curry sauce.',                N'/Videos/chapters/kc_ch04.mp4', '2024-10-30 13:20:00', '2024-10-30 13:20:00'),
(12, 3, 5, N'Plating and Serving',                   N'Arrange rice on one side, ladle the curry on the other and slice the katsu at an angle for classic Japanese presentation.',        N'/Videos/chapters/kc_ch05.mp4', '2024-10-30 13:20:00', '2024-10-30 13:20:00'),

-- Course 4: Korean Bibimbap (4 chapters)
(13, 4, 1, N'Bibimbap Components Overview',          N'Understand the five colour philosophy of bibimbap and how each component — rice, namul, protein, egg and sauce — contributes.', N'/Videos/chapters/bbp_ch01.mp4', '2024-12-05 15:40:00', '2024-12-05 15:40:00'),
(14, 4, 2, N'Preparing Namul (Seasoned Vegetables)', N'Blanch, squeeze and individually season spinach, bean sprouts, carrots and courgette with sesame oil and garlic.',              N'/Videos/chapters/bbp_ch02.mp4', '2024-12-05 15:40:00', '2024-12-05 15:40:00'),
(15, 4, 3, N'Making Gochujang Sauce',                N'Blend gochujang, sesame oil, sugar, garlic and vinegar into the signature bibimbap sauce and adjust heat to preference.',        N'/Videos/chapters/bbp_ch03.mp4', '2024-12-05 15:40:00', '2024-12-05 15:40:00'),
(16, 4, 4, N'Assembly and Presentation',             N'Press rice into a hot dolsot stone bowl, arrange vegetables by colour, top with a runny egg and serve sizzling at the table.', N'/Videos/chapters/bbp_ch04.mp4', '2024-12-05 15:40:00', '2024-12-05 15:40:00'),

-- Course 5: Dumplings & Buns (5 chapters)
(17, 5, 1, N'Introduction to Dim Sum',               N'Discover the history and variety of Cantonese dim sum, the yum cha tradition and the equipment you need to get started at home.', N'/Videos/chapters/ds_ch01.mp4', '2025-01-08 08:30:00', '2025-01-08 08:30:00'),
(18, 5, 2, N'Making Dumpling Wrappers',              N'Mix and knead wheat-starch dough, roll it paper-thin and cut rounds sized for har gow and siu mai.',                            N'/Videos/chapters/ds_ch02.mp4', '2025-01-08 08:30:00', '2025-01-08 08:30:00'),
(19, 5, 3, N'Preparing Traditional Fillings',        N'Season and fold shrimp filling for har gow and combine pork-and-prawn filling with water chestnuts for juicy siu mai.',         N'/Videos/chapters/ds_ch03.mp4', '2025-01-08 08:30:00', '2025-01-08 08:30:00'),
(20, 5, 4, N'Folding and Pleating Techniques',       N'Practice the seven-pleat har gow fold and the open-top siu mai gather until your dumplings hold their shape after steaming.',    N'/Videos/chapters/ds_ch04.mp4', '2025-01-08 08:30:00', '2025-01-08 08:30:00'),
(21, 5, 5, N'Steaming Methods and Serving',          N'Line bamboo steamers correctly, control water levels and steam at the right intensity for delicate, translucent dim sum.',       N'/Videos/chapters/ds_ch05.mp4', '2025-01-08 08:30:00', '2025-01-08 08:30:00'),

-- Course 6: Homemade Ramen Workshop (6 chapters)
(22, 6, 1, N'Ramen Styles and Components',           N'Survey the four main ramen styles — tonkotsu, shoyu, shio and miso — and understand the role of broth, tare, noodles and toppings.', N'/Videos/chapters/ram_ch01.mp4', '2024-11-12 09:45:00', '2024-11-12 09:45:00'),
(23, 6, 2, N'Making the Tonkotsu Broth',             N'Blanch and roast pork bones, then simmer at a rolling boil for 10–18 hours to extract collagen and create a creamy white broth.',     N'/Videos/chapters/ram_ch02.mp4', '2024-11-12 09:45:00', '2024-11-12 09:45:00'),
(24, 6, 3, N'Preparing Fresh Ramen Noodles',         N'Mix bread flour with kansui water, knead, rest and roll the dough to produce springy, slightly alkaline yellow ramen noodles.',       N'/Videos/chapters/ram_ch03.mp4', '2024-11-12 09:45:00', '2024-11-12 09:45:00'),
(25, 6, 4, N'Chashu Pork and Marinated Eggs',        N'Roll and braise pork belly in soy, mirin and sake until tender, then soft-boil and marinate eggs for ajitsuke tamago.',              N'/Videos/chapters/ram_ch04.mp4', '2024-11-12 09:45:00', '2024-11-12 09:45:00'),
(26, 6, 5, N'Tare and Aromatic Oil',                 N'Prepare a soy-based tare to season each bowl and infuse oil with garlic and ginger for the aromatic finishing touch.',                N'/Videos/chapters/ram_ch05.mp4', '2024-11-12 09:45:00', '2024-11-12 09:45:00'),
(27, 6, 6, N'Bowl Assembly and Presentation',        N'Add tare to the bowl first, pour in broth, arrange noodles, then layer chashu, egg, nori and bamboo shoots for the perfect bowl.',   N'/Videos/chapters/ram_ch06.mp4', '2024-11-12 09:45:00', '2024-11-12 09:45:00');
SET IDENTITY_INSERT Chapters OFF;
GO

-- ────────────────────────────────────────────────────────────
-- 5. Enrollments (11 records)
--    Emma (7):  Courses 1, 2, 3
--    Raj (8):   Courses 4, 5, 6
--    Sofia (9): Courses 1, 3
--    David(10): Courses 2, 4, 5
-- ────────────────────────────────────────────────────────────
SET IDENTITY_INSERT Enrollments ON;
INSERT INTO Enrollments (EnrollmentId, UserId, CourseId, EnrollmentDate, Progress, Status, CreatedAt, UpdatedAt) VALUES
( 1,  7, 1, '2025-02-10', 75,  N'In Progress', '2025-02-10 10:00:00', '2025-02-17 18:00:00'),  -- Emma  → Yangzhou FR   (3/4 ch)
( 2,  7, 2, '2025-01-15', 100, N'Completed',   '2025-01-15 14:00:00', '2025-01-21 20:00:00'),  -- Emma  → Carbonara     (3/3 ch)
( 3,  7, 3, '2025-03-01', 40,  N'In Progress', '2025-03-01 11:00:00', '2025-03-05 19:00:00'),  -- Emma  → Katsu Curry   (2/5 ch)
( 4,  8, 4, '2025-01-20', 100, N'Completed',   '2025-01-20 09:00:00', '2025-01-28 21:00:00'),  -- Raj   → Bibimbap      (4/4 ch)
( 5,  8, 5, '2025-02-05', 60,  N'In Progress', '2025-02-05 10:00:00', '2025-02-12 22:00:00'),  -- Raj   → Dumplings     (3/5 ch)
( 6,  8, 6, '2025-03-10', 17,  N'In Progress', '2025-03-10 13:00:00', '2025-03-12 20:00:00'),  -- Raj   → Ramen         (1/6 ch)
( 7,  9, 1, '2025-02-20', 50,  N'In Progress', '2025-02-20 15:00:00', '2025-02-24 18:00:00'),  -- Sofia → Yangzhou FR   (2/4 ch)
( 8,  9, 3, '2025-03-15', 20,  N'In Progress', '2025-03-15 09:00:00', '2025-03-17 17:00:00'),  -- Sofia → Katsu Curry   (1/5 ch)
( 9, 10, 2, '2025-01-25', 100, N'Completed',   '2025-01-25 11:00:00', '2025-01-31 23:00:00'),  -- David → Carbonara     (3/3 ch)
(10, 10, 4, '2025-02-15', 75,  N'In Progress', '2025-02-15 08:00:00', '2025-02-21 19:00:00'),  -- David → Bibimbap      (3/4 ch)
(11, 10, 5, '2025-03-03', 20,  N'In Progress', '2025-03-03 12:00:00', '2025-03-05 16:00:00');  -- David → Dumplings     (1/5 ch)
SET IDENTITY_INSERT Enrollments OFF;
GO

-- ────────────────────────────────────────────────────────────
-- 6. UserChapterProgress (34 records)
--    ChapterId must belong to the course of the enrollment.
-- ────────────────────────────────────────────────────────────
SET IDENTITY_INSERT UserChapterProgress ON;
INSERT INTO UserChapterProgress (ProgressId, UserId, EnrollmentId, ChapterId, IsCompleted, CompletedDate, CreatedAt, UpdatedAt) VALUES
-- Enrollment 1: Emma (7) → Course 1 (Ch 1–4); completed 1,2,3
( 1,  7,  1,  1, 1, '2025-02-12', '2025-02-10 10:00:00', '2025-02-12 18:00:00'),
( 2,  7,  1,  2, 1, '2025-02-14', '2025-02-10 10:00:00', '2025-02-14 19:00:00'),
( 3,  7,  1,  3, 1, '2025-02-16', '2025-02-10 10:00:00', '2025-02-16 20:00:00'),
( 4,  7,  1,  4, 0, NULL,         '2025-02-10 10:00:00', '2025-02-16 20:00:00'),

-- Enrollment 2: Emma (7) → Course 2 (Ch 5–7); completed all
( 5,  7,  2,  5, 1, '2025-01-17', '2025-01-15 14:00:00', '2025-01-17 20:00:00'),
( 6,  7,  2,  6, 1, '2025-01-19', '2025-01-15 14:00:00', '2025-01-19 21:00:00'),
( 7,  7,  2,  7, 1, '2025-01-21', '2025-01-15 14:00:00', '2025-01-21 22:00:00'),

-- Enrollment 3: Emma (7) → Course 3 (Ch 8–12); completed 8,9
( 8,  7,  3,  8, 1, '2025-03-03', '2025-03-01 11:00:00', '2025-03-03 19:00:00'),
( 9,  7,  3,  9, 1, '2025-03-05', '2025-03-01 11:00:00', '2025-03-05 20:00:00'),
(10,  7,  3, 10, 0, NULL,         '2025-03-01 11:00:00', '2025-03-05 20:00:00'),

-- Enrollment 4: Raj (8) → Course 4 (Ch 13–16); completed all
(11,  8,  4, 13, 1, '2025-01-22', '2025-01-20 09:00:00', '2025-01-22 18:00:00'),
(12,  8,  4, 14, 1, '2025-01-24', '2025-01-20 09:00:00', '2025-01-24 19:00:00'),
(13,  8,  4, 15, 1, '2025-01-26', '2025-01-20 09:00:00', '2025-01-26 20:00:00'),
(14,  8,  4, 16, 1, '2025-01-28', '2025-01-20 09:00:00', '2025-01-28 21:00:00'),

-- Enrollment 5: Raj (8) → Course 5 (Ch 17–21); completed 17,18,19
(15,  8,  5, 17, 1, '2025-02-08', '2025-02-05 10:00:00', '2025-02-08 18:00:00'),
(16,  8,  5, 18, 1, '2025-02-10', '2025-02-05 10:00:00', '2025-02-10 19:00:00'),
(17,  8,  5, 19, 1, '2025-02-12', '2025-02-05 10:00:00', '2025-02-12 20:00:00'),
(18,  8,  5, 20, 0, NULL,         '2025-02-05 10:00:00', '2025-02-12 20:00:00'),

-- Enrollment 6: Raj (8) → Course 6 (Ch 22–27); completed 22
(19,  8,  6, 22, 1, '2025-03-12', '2025-03-10 13:00:00', '2025-03-12 20:00:00'),
(20,  8,  6, 23, 0, NULL,         '2025-03-10 13:00:00', '2025-03-12 20:00:00'),

-- Enrollment 7: Sofia (9) → Course 1 (Ch 1–4); completed 1,2
(21,  9,  7,  1, 1, '2025-02-22', '2025-02-20 15:00:00', '2025-02-22 18:00:00'),
(22,  9,  7,  2, 1, '2025-02-24', '2025-02-20 15:00:00', '2025-02-24 19:00:00'),
(23,  9,  7,  3, 0, NULL,         '2025-02-20 15:00:00', '2025-02-24 19:00:00'),

-- Enrollment 8: Sofia (9) → Course 3 (Ch 8–12); completed 8
(24,  9,  8,  8, 1, '2025-03-17', '2025-03-15 09:00:00', '2025-03-17 17:00:00'),
(25,  9,  8,  9, 0, NULL,         '2025-03-15 09:00:00', '2025-03-17 17:00:00'),

-- Enrollment 9: David (10) → Course 2 (Ch 5–7); completed all
(26, 10,  9,  5, 1, '2025-01-27', '2025-01-25 11:00:00', '2025-01-27 20:00:00'),
(27, 10,  9,  6, 1, '2025-01-29', '2025-01-25 11:00:00', '2025-01-29 21:00:00'),
(28, 10,  9,  7, 1, '2025-01-31', '2025-01-25 11:00:00', '2025-01-31 22:00:00'),

-- Enrollment 10: David (10) → Course 4 (Ch 13–16); completed 13,14,15
(29, 10, 10, 13, 1, '2025-02-17', '2025-02-15 08:00:00', '2025-02-17 19:00:00'),
(30, 10, 10, 14, 1, '2025-02-19', '2025-02-15 08:00:00', '2025-02-19 20:00:00'),
(31, 10, 10, 15, 1, '2025-02-21', '2025-02-15 08:00:00', '2025-02-21 21:00:00'),
(32, 10, 10, 16, 0, NULL,         '2025-02-15 08:00:00', '2025-02-21 21:00:00'),

-- Enrollment 11: David (10) → Course 5 (Ch 17–21); completed 17
(33, 10, 11, 17, 1, '2025-03-05', '2025-03-03 12:00:00', '2025-03-05 16:00:00'),
(34, 10, 11, 18, 0, NULL,         '2025-03-03 12:00:00', '2025-03-05 16:00:00');
SET IDENTITY_INSERT UserChapterProgress OFF;
GO

-- ────────────────────────────────────────────────────────────
-- 7. QuizResults (29 records — includes failed retakes)
-- ────────────────────────────────────────────────────────────
SET IDENTITY_INSERT QuizResults ON;
INSERT INTO QuizResults (ResultId, UserId, ChapterId, Score, Status, CompletedDate, CreatedAt) VALUES
-- Emma (7) — Yangzhou FR (Ch 1–3)
( 1,  7,  1, 85, N'Passed', '2025-02-12', '2025-02-12 19:00:00'),
( 2,  7,  2, 90, N'Passed', '2025-02-14', '2025-02-14 20:00:00'),
( 3,  7,  3, 50, N'Failed', '2025-02-15', '2025-02-15 18:00:00'),  -- first attempt failed
( 4,  7,  3, 75, N'Passed', '2025-02-16', '2025-02-16 20:00:00'),  -- retake passed
-- Emma (7) — Carbonara (Ch 5–7)
( 5,  7,  5, 80, N'Passed', '2025-01-17', '2025-01-17 21:00:00'),
( 6,  7,  6, 88, N'Passed', '2025-01-19', '2025-01-19 22:00:00'),
( 7,  7,  7, 72, N'Passed', '2025-01-21', '2025-01-21 23:00:00'),
-- Emma (7) — Katsu Curry (Ch 8–9)
( 8,  7,  8, 80, N'Passed', '2025-03-03', '2025-03-03 20:00:00'),
( 9,  7,  9, 65, N'Passed', '2025-03-05', '2025-03-05 21:00:00'),
-- Raj (8) — Bibimbap (Ch 13–16)
(10,  8, 13, 75, N'Passed', '2025-01-22', '2025-01-22 19:00:00'),
(11,  8, 14, 88, N'Passed', '2025-01-24', '2025-01-24 20:00:00'),
(12,  8, 15, 45, N'Failed', '2025-01-25', '2025-01-25 18:00:00'),  -- first attempt failed
(13,  8, 15, 70, N'Passed', '2025-01-26', '2025-01-26 20:00:00'),  -- retake passed
(14,  8, 16, 82, N'Passed', '2025-01-28', '2025-01-28 21:00:00'),
-- Raj (8) — Dumplings (Ch 17–19)
(15,  8, 17, 90, N'Passed', '2025-02-08', '2025-02-08 19:00:00'),
(16,  8, 18, 85, N'Passed', '2025-02-10', '2025-02-10 20:00:00'),
(17,  8, 19, 55, N'Failed', '2025-02-11', '2025-02-11 18:00:00'),  -- first attempt failed
(18,  8, 19, 78, N'Passed', '2025-02-12', '2025-02-12 20:00:00'),  -- retake passed
-- Raj (8) — Ramen (Ch 22)
(19,  8, 22, 60, N'Passed', '2025-03-12', '2025-03-12 21:00:00'),
-- Sofia (9) — Yangzhou FR (Ch 1–2)
(20,  9,  1, 70, N'Passed', '2025-02-22', '2025-02-22 19:00:00'),
(21,  9,  2, 65, N'Passed', '2025-02-24', '2025-02-24 20:00:00'),
-- Sofia (9) — Katsu Curry (Ch 8)
(22,  9,  8, 78, N'Passed', '2025-03-17', '2025-03-17 18:00:00'),
-- David (10) — Carbonara (Ch 5–7)
(23, 10,  5, 92, N'Passed', '2025-01-27', '2025-01-27 21:00:00'),
(24, 10,  6, 88, N'Passed', '2025-01-29', '2025-01-29 22:00:00'),
(25, 10,  7, 84, N'Passed', '2025-01-31', '2025-01-31 23:00:00'),
-- David (10) — Bibimbap (Ch 13–15)
(26, 10, 13, 76, N'Passed', '2025-02-17', '2025-02-17 20:00:00'),
(27, 10, 14, 80, N'Passed', '2025-02-19', '2025-02-19 21:00:00'),
(28, 10, 15, 68, N'Passed', '2025-02-21', '2025-02-21 22:00:00'),
-- David (10) — Dumplings (Ch 17)
(29, 10, 17, 85, N'Passed', '2025-03-05', '2025-03-05 17:00:00');
SET IDENTITY_INSERT QuizResults OFF;
GO

-- ────────────────────────────────────────────────────────────
-- 8. Comments (11 records)
-- ────────────────────────────────────────────────────────────
SET IDENTITY_INSERT Comments ON;
INSERT INTO Comments (CommentId, CourseId, UserId, CommentText, Rating, CreatedDate, CreatedAt, UpdatedAt) VALUES
( 1, 1,  7, N'The wok hei technique completely changed my fried rice. I never realised how much difference the heat made. My family now prefers my version over takeaway!',                                                          5, '2025-02-18', '2025-02-18 20:00:00', '2025-02-18 20:00:00'),
( 2, 2,  7, N'Finally a carbonara recipe that explains the science behind the emulsion. No more scrambled eggs! The guanciale tip was a game changer — do not substitute bacon.',                                                    5, '2025-01-23', '2025-01-23 21:00:00', '2025-01-23 21:00:00'),
( 3, 3,  7, N'The curry roux from scratch is much better than block curry. It took me two tries to get the consistency right but the end result is incredible. Would love more tips on spice ratios.',                              4, '2025-03-08', '2025-03-08 19:00:00', '2025-03-08 19:00:00'),
( 4, 4,  8, N'Bibimbap was the first Korean dish I ever cooked properly. The namul seasoning guide is spot on and the gochujang sauce recipe alone is worth enrolling for. Highly recommended!',                                    5, '2025-01-30', '2025-01-30 20:00:00', '2025-01-30 20:00:00'),
( 5, 5,  8, N'Dim sum is genuinely hard. I failed the pleating three times before it clicked. The slow-motion folding demonstration in chapter 4 is the most useful video I have ever watched in a cooking course.',               4, '2025-02-15', '2025-02-15 21:00:00', '2025-02-15 21:00:00'),
( 6, 6,  8, N'Making ramen from scratch over two days was an adventure. The tonkotsu broth recipe is pure gold — rich, creamy and deeply savoury. The chashu pork was fall-apart perfect. Worth every hour of effort.',           5, '2025-03-15', '2025-03-15 22:00:00', '2025-03-15 22:00:00'),
( 7, 1,  9, N'Great introduction to Yangzhou fried rice. The section on rice preparation is really clear. Docking one star because I wished there was more detail on ingredient substitutions for outside China.',                  4, '2025-02-26', '2025-02-26 19:00:00', '2025-02-26 19:00:00'),
( 8, 3,  9, N'The katsu technique is excellent but the curry chapter moves a bit fast. I had to replay the roux section several times. Overall a good course with clear production quality.',                                        3, '2025-03-20', '2025-03-20 18:00:00', '2025-03-20 18:00:00'),
( 9, 2, 10, N'As an Italian food lover this course exceeded my expectations. The explanation of why cream does not belong in carbonara was delivered with passion and the recipe is flawless. Ten out of five if I could!',          5, '2025-02-02', '2025-02-02 21:00:00', '2025-02-02 21:00:00'),
(10, 4, 10, N'Loved the stone bowl technique. My rice got that gorgeous crispy bottom on the first try. The egg runny-yolk trick ties the whole dish together beautifully.',                                                        4, '2025-02-22', '2025-02-22 20:00:00', '2025-02-22 20:00:00'),
(11, 5, 10, N'The filling recipes are authentic and delicious. My har gow wrappers were a little thick on the first attempt but the course gives you the confidence to keep practising. Great community recipe sharing too.',       5, '2025-03-08', '2025-03-08 20:00:00', '2025-03-08 20:00:00');
SET IDENTITY_INSERT Comments OFF;
GO

-- ────────────────────────────────────────────────────────────
-- 9. SharerRegistrations (10 records)
-- ────────────────────────────────────────────────────────────
SET IDENTITY_INSERT SharerRegistrations ON;
INSERT INTO SharerRegistrations (RegistrationId, UserId, RequestDate, ProofDocument, Status, ReviewedBy, ReviewedDate, CreatedAt, UpdatedAt) VALUES
-- Accepted sharers
(1, 4, '2024-05-20', N'/Uploads/ProofDocuments/professional_chef_license_liwei.pdf',     N'Accepted', 1, '2024-05-25', '2024-05-20 09:00:00', '2024-05-25 10:00:00'),
(2, 5, '2024-04-10', N'/Uploads/ProofDocuments/culinary_school_diploma_marco.pdf',        N'Accepted', 2, '2024-04-15', '2024-04-10 11:00:00', '2024-04-15 14:00:00'),
(3, 6, '2024-06-15', N'/Uploads/ProofDocuments/chef_certification_yuki.pdf',              N'Accepted', 1, '2024-06-20', '2024-06-15 10:00:00', '2024-06-20 09:00:00'),
-- Emma (7) — first attempt Rejected, re-applied Pending
(4, 7, '2025-01-03', N'/Uploads/ProofDocuments/cooking_class_certificate_emma.pdf',       N'Rejected', 3, '2025-01-10', '2025-01-03 10:00:00', '2025-01-10 15:00:00'),
(5, 7, '2025-02-18', N'/Uploads/ProofDocuments/professional_training_certificate_emma.pdf',N'Pending', NULL, NULL,       '2025-02-18 11:00:00', '2025-02-18 11:00:00'),
-- Raj (8) — first attempt Rejected, re-applied Pending
(6, 8, '2025-01-08', N'/Uploads/ProofDocuments/home_chef_portfolio_raj.pdf',              N'Rejected', 3, '2025-01-15', '2025-01-08 09:00:00', '2025-01-15 16:00:00'),
(7, 8, '2025-02-23', N'/Uploads/ProofDocuments/culinary_workshop_certificate_raj.pdf',    N'Pending',  NULL, NULL,       '2025-02-23 10:00:00', '2025-02-23 10:00:00'),
-- Sofia (9) — Rejected
(8, 9, '2025-01-28', N'/Uploads/ProofDocuments/cooking_diploma_sofia.pdf',                N'Rejected', 2, '2025-02-05', '2025-01-28 12:00:00', '2025-02-05 14:00:00'),
-- David (10) — first attempt Rejected, re-applied Pending
(9, 10,'2025-01-18', N'/Uploads/ProofDocuments/korean_cuisine_certificate_david.pdf',     N'Rejected', 3, '2025-01-25', '2025-01-18 09:00:00', '2025-01-25 17:00:00'),
(10,10,'2025-02-28', N'/Uploads/ProofDocuments/chef_training_completion_david.pdf',       N'Pending',  NULL, NULL,       '2025-02-28 10:00:00', '2025-02-28 10:00:00');
SET IDENTITY_INSERT SharerRegistrations OFF;
GO

-- ────────────────────────────────────────────────────────────
-- 11. ReportedContent (10 records)
-- ────────────────────────────────────────────────────────────
SET IDENTITY_INSERT ReportedContent ON;
INSERT INTO ReportedContent (ReportId, CourseId, ReporterId, Reason, ReportDate, Status, ReviewedBy, ReviewedDate, CreatedAt, UpdatedAt) VALUES
( 1, 1,  7, N'Some video segments have low resolution, making it difficult to see the wok technique clearly.',                                  '2025-02-15', N'Pending', NULL, NULL,         '2025-02-15 10:00:00', '2025-02-15 10:00:00'),
( 2, 2,  8, N'There is a minor audio sync issue in chapter 2 — the narration is about one second ahead of the on-screen action.',              '2025-02-01', N'Ignored', 1,    '2025-02-05', '2025-02-01 11:00:00', '2025-02-05 09:00:00'),
( 3, 3,  9, N'The ingredient list does not specify the exact quantity of curry powder required, which is confusing for beginners.',             '2025-03-16', N'Pending', NULL, NULL,         '2025-03-16 09:00:00', '2025-03-16 09:00:00'),
( 4, 4, 10, N'The pacing in the vegetable preparation section is too fast for beginners; closer camera angles on the knife work would help.',  '2025-02-20', N'Ignored', 2,    '2025-02-23', '2025-02-20 14:00:00', '2025-02-23 10:00:00'),
( 5, 5,  7, N'Background music in chapters 3 and 4 is noticeably louder than the instructor voice, making it hard to hear the instructions.', '2025-03-05', N'Ignored', 1,    '2025-03-07', '2025-03-05 10:00:00', '2025-03-07 09:00:00'),
( 6, 6,  8, N'Chapter 3 contains a short segment of copyrighted music that is not licensed for use on the platform.',                          '2025-03-14', N'Banned',  3,    '2025-03-16', '2025-03-14 11:00:00', '2025-03-16 10:00:00'),
( 7, 1,  9, N'Subtitles in the plating chapter contain several mistranslations that change the meaning of the technique being described.',     '2025-02-25', N'Ignored', 2,    '2025-02-28', '2025-02-25 15:00:00', '2025-02-28 09:00:00'),
( 8, 2, 10, N'The quantity of Pecorino Romano shown in the video does not match the amount written in the recipe card.',                       '2025-02-03', N'Pending', NULL, NULL,         '2025-02-03 12:00:00', '2025-02-03 12:00:00'),
( 9, 3,  7, N'The course thumbnail image does not accurately represent the finished dish shown in the final chapter.',                          '2025-03-10', N'Ignored', 1,    '2025-03-12', '2025-03-10 09:00:00', '2025-03-12 11:00:00'),
(10, 4,  8, N'The historical background section in chapter 1 is missing key context about the regional origins of bibimbap.',                  '2025-02-25', N'Pending', NULL, NULL,         '2025-02-25 13:00:00', '2025-02-25 13:00:00');
SET IDENTITY_INSERT ReportedContent OFF;
GO

-- ────────────────────────────────────────────────────────────
-- 12. PlatformAnalytics (12 records — Jan to Dec 2025)
-- ────────────────────────────────────────────────────────────
SET IDENTITY_INSERT PlatformAnalytics ON;
INSERT INTO PlatformAnalytics (AnalyticsId, RecordDate, NewUsersCount, TotalUsersCount, ActiveCoursesCount, TotalCoursesCount, CreatedAt) VALUES
( 1, '2025-01-31',  15,  15, 4, 4, '2025-02-01 00:00:00'),
( 2, '2025-02-28',   5,  20, 4, 4, '2025-03-01 00:00:00'),
( 3, '2025-03-31',   8,  28, 5, 5, '2025-04-01 00:00:00'),
( 4, '2025-04-30',  12,  40, 6, 6, '2025-05-01 00:00:00'),
( 5, '2025-05-31',  18,  58, 6, 6, '2025-06-01 00:00:00'),
( 6, '2025-06-30',  22,  80, 6, 6, '2025-07-01 00:00:00'),
( 7, '2025-07-31',  30, 110, 6, 6, '2025-08-01 00:00:00'),
( 8, '2025-08-31',  35, 145, 6, 6, '2025-09-01 00:00:00'),
( 9, '2025-09-30',  42, 187, 6, 6, '2025-10-01 00:00:00'),
(10, '2025-10-31',  55, 242, 6, 6, '2025-11-01 00:00:00'),
(11, '2025-11-30',  48, 290, 6, 6, '2025-12-01 00:00:00'),
(12, '2025-12-31',  62, 352, 6, 6, '2026-01-01 00:00:00');
SET IDENTITY_INSERT PlatformAnalytics OFF;
GO

-- ============================================================
-- DML: Questions & Answers
-- 2 questions per chapter (54 total), 4 answers each (216 total)
-- Exactly 1 correct answer (IsCorrect=1) per question
-- ============================================================

SET IDENTITY_INSERT Questions ON;
INSERT INTO Questions (QuestionId, ChapterId, QuestionText, QuestionOrder, CreatedAt, UpdatedAt) VALUES
-- ── Course 1: Yangzhou Fried Rice ──
-- Ch 1: Introduction
( 1,  1, N'Which city is Yangzhou Fried Rice originally from?',                                       1, '2024-10-15 09:00:00', '2024-10-15 09:00:00'),
( 2,  1, N'What cooking technique gives fried rice its characteristic smoky aroma?',                  2, '2024-10-15 09:00:00', '2024-10-15 09:00:00'),
-- Ch 2: Ingredient Selection
( 3,  2, N'Which type of rice is best suited for Yangzhou fried rice?',                               1, '2024-10-15 09:00:00', '2024-10-15 09:00:00'),
( 4,  2, N'Why is day-old rice preferred over freshly cooked rice for fried rice?',                   2, '2024-10-15 09:00:00', '2024-10-15 09:00:00'),
-- Ch 3: Wok Techniques
( 5,  3, N'What does the Chinese term "wok hei" literally translate to?',                             1, '2024-10-15 09:00:00', '2024-10-15 09:00:00'),
( 6,  3, N'At what heat level should Yangzhou fried rice be cooked for best results?',                2, '2024-10-15 09:00:00', '2024-10-15 09:00:00'),
-- Ch 4: Plating
( 7,  4, N'What garnish is traditionally used to finish a plate of Yangzhou Fried Rice?',             1, '2024-10-15 09:00:00', '2024-10-15 09:00:00'),
( 8,  4, N'Which tool is typically used to mould fried rice into a dome shape for plating?',          2, '2024-10-15 09:00:00', '2024-10-15 09:00:00'),

-- ── Course 2: Classic Italian Carbonara ──
-- Ch 5: Carbonara Fundamentals
( 9,  5, N'Which Italian city is carbonara traditionally associated with?',                           1, '2024-11-20 10:15:00', '2024-11-20 10:15:00'),
(10,  5, N'What makes authentic carbonara fundamentally different from a cream-based pasta?',         2, '2024-11-20 10:15:00', '2024-11-20 10:15:00'),
-- Ch 6: Cooking Pasta and Guanciale
(11,  6, N'What is guanciale?',                                                                       1, '2024-11-20 10:15:00', '2024-11-20 10:15:00'),
(12,  6, N'How salty should pasta water be when cooking carbonara?',                                  2, '2024-11-20 10:15:00', '2024-11-20 10:15:00'),
-- Ch 7: Creamy Egg Sauce
(13,  7, N'Which cheese is traditionally used in authentic Italian carbonara?',                       1, '2024-11-20 10:15:00', '2024-11-20 10:15:00'),
(14,  7, N'How do you prevent the eggs from scrambling when making carbonara sauce?',                 2, '2024-11-20 10:15:00', '2024-11-20 10:15:00'),

-- ── Course 3: Japanese Katsu Curry ──
-- Ch 8: Japanese Curry Basics
(15,  8, N'Japanese curry is most closely influenced by which country''s cuisine?',                   1, '2024-10-30 13:20:00', '2024-10-30 13:20:00'),
(16,  8, N'What characteristic makes Japanese curry milder and sweeter than Indian curry?',           2, '2024-10-30 13:20:00', '2024-10-30 13:20:00'),
-- Ch 9: Curry Roux from Scratch
(17,  9, N'What forms the base of a traditional curry roux made from scratch?',                       1, '2024-10-30 13:20:00', '2024-10-30 13:20:00'),
(18,  9, N'At which stage of making the roux are the ground spices added?',                           2, '2024-10-30 13:20:00', '2024-10-30 13:20:00'),
-- Ch 10: Preparing Tonkatsu
(19, 10, N'What is the correct breading sequence for tonkatsu?',                                      1, '2024-10-30 13:20:00', '2024-10-30 13:20:00'),
(20, 10, N'What oil temperature is ideal for frying tonkatsu to achieve a crispy crust?',             2, '2024-10-30 13:20:00', '2024-10-30 13:20:00'),
-- Ch 11: Cooking the Curry Sauce
(21, 11, N'Which vegetables are most commonly used in Japanese curry?',                               1, '2024-10-30 13:20:00', '2024-10-30 13:20:00'),
(22, 11, N'Why is the roux typically dissolved into the curry sauce at the end of cooking?',          2, '2024-10-30 13:20:00', '2024-10-30 13:20:00'),
-- Ch 12: Plating and Serving
(23, 12, N'How is katsu curry traditionally presented on the plate?',                                 1, '2024-10-30 13:20:00', '2024-10-30 13:20:00'),
(24, 12, N'Which condiment is most commonly served alongside Japanese katsu curry?',                  2, '2024-10-30 13:20:00', '2024-10-30 13:20:00'),

-- ── Course 4: Traditional Korean Bibimbap ──
-- Ch 13: Components Overview
(25, 13, N'What does the Korean word "bibimbap" mean in English?',                                    1, '2024-12-05 15:40:00', '2024-12-05 15:40:00'),
(26, 13, N'Which vessel is used for the traditional sizzling hot-stone bibimbap?',                    2, '2024-12-05 15:40:00', '2024-12-05 15:40:00'),
-- Ch 14: Preparing Namul
(27, 14, N'Which two seasonings are essential for making Korean namul vegetables?',                   1, '2024-12-05 15:40:00', '2024-12-05 15:40:00'),
(28, 14, N'How are leafy vegetables such as spinach typically prepared for namul?',                   2, '2024-12-05 15:40:00', '2024-12-05 15:40:00'),
-- Ch 15: Gochujang Sauce
(29, 15, N'What is gochujang?',                                                                       1, '2024-12-05 15:40:00', '2024-12-05 15:40:00'),
(30, 15, N'Which ingredient is added to the gochujang sauce to balance its spiciness?',               2, '2024-12-05 15:40:00', '2024-12-05 15:40:00'),
-- Ch 16: Assembly and Presentation
(31, 16, N'In what order are ingredients typically arranged when assembling bibimbap?',               1, '2024-12-05 15:40:00', '2024-12-05 15:40:00'),
(32, 16, N'What style of egg is traditionally placed on top of a bibimbap bowl?',                     2, '2024-12-05 15:40:00', '2024-12-05 15:40:00'),

-- ── Course 5: Dumplings & Buns ──
-- Ch 17: Introduction to Dim Sum
(33, 17, N'What does the Cantonese term "dim sum" roughly translate to?',                             1, '2025-01-08 08:30:00', '2025-01-08 08:30:00'),
(34, 17, N'What is the Chinese tradition of eating dim sum with tea called?',                         2, '2025-01-08 08:30:00', '2025-01-08 08:30:00'),
-- Ch 18: Making Wrappers
(35, 18, N'Which type of flour is used to make the best transparent har gow wrappers?',               1, '2025-01-08 08:30:00', '2025-01-08 08:30:00'),
(36, 18, N'How thin should a dim sum wrapper ideally be rolled?',                                     2, '2025-01-08 08:30:00', '2025-01-08 08:30:00'),
-- Ch 19: Preparing Fillings
(37, 19, N'What is the primary filling ingredient in classic har gow dumplings?',                     1, '2025-01-08 08:30:00', '2025-01-08 08:30:00'),
(38, 19, N'Which ingredient is commonly added to siu mai filling to keep it moist and juicy?',        2, '2025-01-08 08:30:00', '2025-01-08 08:30:00'),
-- Ch 20: Folding and Pleating
(39, 20, N'How many pleats does a well-made traditional har gow typically have on one side?',         1, '2025-01-08 08:30:00', '2025-01-08 08:30:00'),
(40, 20, N'Which hand motion is used to create pleats when folding har gow?',                         2, '2025-01-08 08:30:00', '2025-01-08 08:30:00'),
-- Ch 21: Steaming Methods
(41, 21, N'What is placed inside bamboo steamers to prevent dim sum from sticking?',                  1, '2025-01-08 08:30:00', '2025-01-08 08:30:00'),
(42, 21, N'How much water should the pot beneath the steamer contain?',                               2, '2025-01-08 08:30:00', '2025-01-08 08:30:00'),

-- ── Course 6: Homemade Ramen Workshop ──
-- Ch 22: Ramen Styles
(43, 22, N'Which ramen style is characterised by a rich, opaque, milky pork bone broth?',            1, '2024-11-12 09:45:00', '2024-11-12 09:45:00'),
(44, 22, N'What is "tare" in the context of ramen preparation?',                                      2, '2024-11-12 09:45:00', '2024-11-12 09:45:00'),
-- Ch 23: Tonkotsu Broth
(45, 23, N'How many hours does tonkotsu broth typically need to simmer for full flavour?',            1, '2024-11-12 09:45:00', '2024-11-12 09:45:00'),
(46, 23, N'What gives tonkotsu broth its distinctive creamy white colour?',                           2, '2024-11-12 09:45:00', '2024-11-12 09:45:00'),
-- Ch 24: Fresh Ramen Noodles
(47, 24, N'Which ingredient makes ramen noodles springy and gives them their yellow colour?',         1, '2024-11-12 09:45:00', '2024-11-12 09:45:00'),
(48, 24, N'How long should fresh ramen noodle dough be rested before rolling?',                       2, '2024-11-12 09:45:00', '2024-11-12 09:45:00'),
-- Ch 25: Chashu and Eggs
(49, 25, N'Which cut of pork is most commonly used for ramen chashu?',                                1, '2024-11-12 09:45:00', '2024-11-12 09:45:00'),
(50, 25, N'What does the Japanese term "ajitsuke tamago" mean?',                                      2, '2024-11-12 09:45:00', '2024-11-12 09:45:00'),
-- Ch 26: Tare and Aromatic Oil
(51, 26, N'What is the main purpose of tare when assembling a bowl of ramen?',                        1, '2024-11-12 09:45:00', '2024-11-12 09:45:00'),
(52, 26, N'Which aromatic oil is most commonly used as a finishing touch in tonkotsu ramen?',         2, '2024-11-12 09:45:00', '2024-11-12 09:45:00'),
-- Ch 27: Bowl Assembly
(53, 27, N'What is the correct order for assembling a bowl of ramen?',                                1, '2024-11-12 09:45:00', '2024-11-12 09:45:00'),
(54, 27, N'Which topping combination adds both umami depth and textural contrast to a ramen bowl?',   2, '2024-11-12 09:45:00', '2024-11-12 09:45:00');
SET IDENTITY_INSERT Questions OFF;
GO

SET IDENTITY_INSERT Answers ON;
INSERT INTO Answers (AnswerId, QuestionId, AnswerText, IsCorrect, AnswerOrder, CreatedAt) VALUES
-- Q1: Yangzhou origin
(  1,  1, N'Yangzhou, Jiangsu province',          1, 1, '2024-10-15 09:00:00'),
(  2,  1, N'Beijing',                              0, 2, '2024-10-15 09:00:00'),
(  3,  1, N'Guangzhou',                            0, 3, '2024-10-15 09:00:00'),
(  4,  1, N'Chengdu',                              0, 4, '2024-10-15 09:00:00'),
-- Q2: Smoky aroma technique
(  5,  2, N'Wok hei (breath of the wok)',          1, 1, '2024-10-15 09:00:00'),
(  6,  2, N'Slow steaming',                        0, 2, '2024-10-15 09:00:00'),
(  7,  2, N'Deep frying',                          0, 3, '2024-10-15 09:00:00'),
(  8,  2, N'Oven roasting',                        0, 4, '2024-10-15 09:00:00'),
-- Q3: Best rice type
(  9,  3, N'Long-grain jasmine rice',              1, 1, '2024-10-15 09:00:00'),
( 10,  3, N'Short-grain sushi rice',               0, 2, '2024-10-15 09:00:00'),
( 11,  3, N'Brown rice',                           0, 3, '2024-10-15 09:00:00'),
( 12,  3, N'Glutinous sticky rice',                0, 4, '2024-10-15 09:00:00'),
-- Q4: Day-old rice
( 13,  4, N'It is drier, so the grains separate more easily in the wok', 1, 1, '2024-10-15 09:00:00'),
( 14,  4, N'It contains more starch for binding',  0, 2, '2024-10-15 09:00:00'),
( 15,  4, N'It cooks faster at high heat',         0, 3, '2024-10-15 09:00:00'),
( 16,  4, N'It absorbs soy sauce more evenly',     0, 4, '2024-10-15 09:00:00'),
-- Q5: Wok hei translation
( 17,  5, N'Breath of the wok',                    1, 1, '2024-10-15 09:00:00'),
( 18,  5, N'Fire of the pan',                      0, 2, '2024-10-15 09:00:00'),
( 19,  5, N'Soul of the chef',                     0, 3, '2024-10-15 09:00:00'),
( 20,  5, N'Spirit of the flame',                  0, 4, '2024-10-15 09:00:00'),
-- Q6: Heat level
( 21,  6, N'Very high heat',                       1, 1, '2024-10-15 09:00:00'),
( 22,  6, N'Low heat',                             0, 2, '2024-10-15 09:00:00'),
( 23,  6, N'Medium heat',                          0, 3, '2024-10-15 09:00:00'),
( 24,  6, N'Medium-low heat',                      0, 4, '2024-10-15 09:00:00'),
-- Q7: Garnish
( 25,  7, N'Spring onion and egg white shreds',    1, 1, '2024-10-15 09:00:00'),
( 26,  7, N'Sesame seeds',                         0, 2, '2024-10-15 09:00:00'),
( 27,  7, N'Fresh coriander',                      0, 3, '2024-10-15 09:00:00'),
( 28,  7, N'Crispy fried shallots',                0, 4, '2024-10-15 09:00:00'),
-- Q8: Dome mould tool
( 29,  8, N'A small bowl',                         1, 1, '2024-10-15 09:00:00'),
( 30,  8, N'A ladle',                              0, 2, '2024-10-15 09:00:00'),
( 31,  8, N'A ring mould',                         0, 3, '2024-10-15 09:00:00'),
( 32,  8, N'A flat spatula',                       0, 4, '2024-10-15 09:00:00'),
-- Q9: Carbonara origin city
( 33,  9, N'Rome',                                 1, 1, '2024-11-20 10:15:00'),
( 34,  9, N'Milan',                                0, 2, '2024-11-20 10:15:00'),
( 35,  9, N'Naples',                               0, 3, '2024-11-20 10:15:00'),
( 36,  9, N'Florence',                             0, 4, '2024-11-20 10:15:00'),
-- Q10: No cream
( 37, 10, N'It uses only eggs and aged cheese for creaminess — no cream',     1, 1, '2024-11-20 10:15:00'),
( 38, 10, N'It uses less butter than a standard cream pasta',                 0, 2, '2024-11-20 10:15:00'),
( 39, 10, N'It uses a lighter type of pasta',                                 0, 3, '2024-11-20 10:15:00'),
( 40, 10, N'It adds a splash of white wine instead of cream',                 0, 4, '2024-11-20 10:15:00'),
-- Q11: What is guanciale
( 41, 11, N'Cured pork cheek (jowl)',              1, 1, '2024-11-20 10:15:00'),
( 42, 11, N'Smoked streaky bacon',                 0, 2, '2024-11-20 10:15:00'),
( 43, 11, N'Cured pork belly (pancetta)',          0, 3, '2024-11-20 10:15:00'),
( 44, 11, N'Dry-cured ham (prosciutto)',           0, 4, '2024-11-20 10:15:00'),
-- Q12: Pasta water saltiness
( 45, 12, N'As salty as the sea',                  1, 1, '2024-11-20 10:15:00'),
( 46, 12, N'Lightly salted',                       0, 2, '2024-11-20 10:15:00'),
( 47, 12, N'Unsalted',                             0, 3, '2024-11-20 10:15:00'),
( 48, 12, N'Just a pinch of salt',                 0, 4, '2024-11-20 10:15:00'),
-- Q13: Cheese in carbonara
( 49, 13, N'Pecorino Romano',                      1, 1, '2024-11-20 10:15:00'),
( 50, 13, N'Parmigiano Reggiano only',             0, 2, '2024-11-20 10:15:00'),
( 51, 13, N'Grana Padano',                         0, 3, '2024-11-20 10:15:00'),
( 52, 13, N'Ricotta',                              0, 4, '2024-11-20 10:15:00'),
-- Q14: Prevent scrambling
( 53, 14, N'Remove the pan from heat before adding the egg-cheese mixture', 1, 1, '2024-11-20 10:15:00'),
( 54, 14, N'Add cold pasta water to cool the eggs first',                   0, 2, '2024-11-20 10:15:00'),
( 55, 14, N'Use only egg whites instead of whole eggs',                     0, 3, '2024-11-20 10:15:00'),
( 56, 14, N'Keep the pan on high heat and stir vigorously',                 0, 4, '2024-11-20 10:15:00'),
-- Q15: Japanese curry influence
( 57, 15, N'India, via British naval influence',   1, 1, '2024-10-30 13:20:00'),
( 58, 15, N'Thailand',                             0, 2, '2024-10-30 13:20:00'),
( 59, 15, N'China',                                0, 3, '2024-10-30 13:20:00'),
( 60, 15, N'Malaysia',                             0, 4, '2024-10-30 13:20:00'),
-- Q16: Milder curry
( 61, 16, N'It uses a butter-flour roux that tempers the spice and adds sweetness',   1, 1, '2024-10-30 13:20:00'),
( 62, 16, N'It uses coconut milk to dilute the heat',                                 0, 2, '2024-10-30 13:20:00'),
( 63, 16, N'It is cooked for a shorter time so spices do not fully bloom',            0, 3, '2024-10-30 13:20:00'),
( 64, 16, N'It omits turmeric entirely',                                              0, 4, '2024-10-30 13:20:00'),
-- Q17: Roux base
( 65, 17, N'Butter and flour',                     1, 1, '2024-10-30 13:20:00'),
( 66, 17, N'Oil and cornstarch',                   0, 2, '2024-10-30 13:20:00'),
( 67, 17, N'Egg and breadcrumbs',                  0, 3, '2024-10-30 13:20:00'),
( 68, 17, N'Rice flour and water',                 0, 4, '2024-10-30 13:20:00'),
-- Q18: When to add spices
( 69, 18, N'After the flour has cooked in the butter to a golden colour',   1, 1, '2024-10-30 13:20:00'),
( 70, 18, N'Before adding the butter to the pan',                           0, 2, '2024-10-30 13:20:00'),
( 71, 18, N'After adding all the liquid to the pot',                        0, 3, '2024-10-30 13:20:00'),
( 72, 18, N'Right at the very end of cooking',                              0, 4, '2024-10-30 13:20:00'),
-- Q19: Tonkatsu breading order
( 73, 19, N'Flour → egg wash → panko breadcrumbs', 1, 1, '2024-10-30 13:20:00'),
( 74, 19, N'Egg wash → flour → panko breadcrumbs', 0, 2, '2024-10-30 13:20:00'),
( 75, 19, N'Panko → flour → egg wash',             0, 3, '2024-10-30 13:20:00'),
( 76, 19, N'Flour → panko → egg wash',             0, 4, '2024-10-30 13:20:00'),
-- Q20: Frying temperature
( 77, 20, N'170–180°C (338–356°F)',                1, 1, '2024-10-30 13:20:00'),
( 78, 20, N'120–130°C (248–266°F)',                0, 2, '2024-10-30 13:20:00'),
( 79, 20, N'200–210°C (392–410°F)',                0, 3, '2024-10-30 13:20:00'),
( 80, 20, N'150–160°C (302–320°F)',                0, 4, '2024-10-30 13:20:00'),
-- Q21: Common vegetables
( 81, 21, N'Potato, carrot and onion',             1, 1, '2024-10-30 13:20:00'),
( 82, 21, N'Broccoli, mushroom and spinach',       0, 2, '2024-10-30 13:20:00'),
( 83, 21, N'Aubergine, courgette and tomato',      0, 3, '2024-10-30 13:20:00'),
( 84, 21, N'Bamboo shoots, corn and peas',         0, 4, '2024-10-30 13:20:00'),
-- Q22: Roux added at end
( 85, 22, N'To control sauce thickness without creating lumps',         1, 1, '2024-10-30 13:20:00'),
( 86, 22, N'Because it adds colour and should not be overcooked',       0, 2, '2024-10-30 13:20:00'),
( 87, 22, N'Because it makes the vegetables cook faster',               0, 3, '2024-10-30 13:20:00'),
( 88, 22, N'To preserve the raw spice aroma at the end',                0, 4, '2024-10-30 13:20:00'),
-- Q23: Katsu curry plating
( 89, 23, N'Rice on one side, curry sauce on the other, sliced katsu arranged on top', 1, 1, '2024-10-30 13:20:00'),
( 90, 23, N'Katsu fully submerged under the curry sauce',               0, 2, '2024-10-30 13:20:00'),
( 91, 23, N'Rice underneath everything with katsu on top',              0, 3, '2024-10-30 13:20:00'),
( 92, 23, N'Curry sauce drizzled only over the rice',                   0, 4, '2024-10-30 13:20:00'),
-- Q24: Condiment served with katsu curry
( 93, 24, N'Tonkatsu sauce (bulldog-style)',        1, 1, '2024-10-30 13:20:00'),
( 94, 24, N'Soy sauce',                            0, 2, '2024-10-30 13:20:00'),
( 95, 24, N'Ketchup',                              0, 3, '2024-10-30 13:20:00'),
( 96, 24, N'Teriyaki sauce',                       0, 4, '2024-10-30 13:20:00'),
-- Q25: Bibimbap meaning
( 97, 25, N'Mixed rice',                           1, 1, '2024-12-05 15:40:00'),
( 98, 25, N'Stone bowl rice',                      0, 2, '2024-12-05 15:40:00'),
( 99, 25, N'Spicy rice',                           0, 3, '2024-12-05 15:40:00'),
(100, 25, N'Colourful rice',                       0, 4, '2024-12-05 15:40:00'),
-- Q26: Stone bowl
(101, 26, N'Dolsot (heavy stone bowl)',             1, 1, '2024-12-05 15:40:00'),
(102, 26, N'Cast iron skillet',                    0, 2, '2024-12-05 15:40:00'),
(103, 26, N'Wooden serving bowl',                  0, 3, '2024-12-05 15:40:00'),
(104, 26, N'Clay pot',                             0, 4, '2024-12-05 15:40:00'),
-- Q27: Namul seasonings
(105, 27, N'Sesame oil and garlic',                1, 1, '2024-12-05 15:40:00'),
(106, 27, N'Soy sauce only',                       0, 2, '2024-12-05 15:40:00'),
(107, 27, N'Gochujang paste',                      0, 3, '2024-12-05 15:40:00'),
(108, 27, N'Fish sauce and lime juice',            0, 4, '2024-12-05 15:40:00'),
-- Q28: Spinach namul preparation
(109, 28, N'Blanched briefly in salted water, then squeezed dry',       1, 1, '2024-12-05 15:40:00'),
(110, 28, N'Stir-fried on high heat with butter',                       0, 2, '2024-12-05 15:40:00'),
(111, 28, N'Roasted in the oven until wilted',                          0, 3, '2024-12-05 15:40:00'),
(112, 28, N'Served completely raw',                                     0, 4, '2024-12-05 15:40:00'),
-- Q29: What is gochujang
(113, 29, N'Korean fermented red chilli paste',    1, 1, '2024-12-05 15:40:00'),
(114, 29, N'Korean soy sauce',                     0, 2, '2024-12-05 15:40:00'),
(115, 29, N'Dried chilli flakes',                  0, 3, '2024-12-05 15:40:00'),
(116, 29, N'Sweet chilli dipping sauce',           0, 4, '2024-12-05 15:40:00'),
-- Q30: Balance spiciness
(117, 30, N'Sugar or honey',                       1, 1, '2024-12-05 15:40:00'),
(118, 30, N'Rice vinegar',                         0, 2, '2024-12-05 15:40:00'),
(119, 30, N'Extra salt',                           0, 3, '2024-12-05 15:40:00'),
(120, 30, N'Sesame seeds',                         0, 4, '2024-12-05 15:40:00'),
-- Q31: Bibimbap assembly order
(121, 31, N'Rice first, then vegetables arranged around the sides, egg placed on top', 1, 1, '2024-12-05 15:40:00'),
(122, 31, N'Vegetables first, then rice, then egg on top',              0, 2, '2024-12-05 15:40:00'),
(123, 31, N'Egg first, then rice, then vegetables around the edges',    0, 3, '2024-12-05 15:40:00'),
(124, 31, N'All ingredients added together and mixed from the start',   0, 4, '2024-12-05 15:40:00'),
-- Q32: Egg style
(125, 32, N'A fried egg with a runny yolk',        1, 1, '2024-12-05 15:40:00'),
(126, 32, N'A hard-boiled egg cut in half',        0, 2, '2024-12-05 15:40:00'),
(127, 32, N'Scrambled egg folded through the rice',0, 3, '2024-12-05 15:40:00'),
(128, 32, N'A poached egg',                        0, 4, '2024-12-05 15:40:00'),
-- Q33: Dim sum meaning
(129, 33, N'Touch the heart',                      1, 1, '2025-01-08 08:30:00'),
(130, 33, N'Small bites',                          0, 2, '2025-01-08 08:30:00'),
(131, 33, N'Morning tea',                          0, 3, '2025-01-08 08:30:00'),
(132, 33, N'Steamed dumplings',                    0, 4, '2025-01-08 08:30:00'),
-- Q34: Yum cha tradition
(133, 34, N'Yum cha',                              1, 1, '2025-01-08 08:30:00'),
(134, 34, N'Cha siu',                              0, 2, '2025-01-08 08:30:00'),
(135, 34, N'Baozi time',                           0, 3, '2025-01-08 08:30:00'),
(136, 34, N'Wonton hour',                          0, 4, '2025-01-08 08:30:00'),
-- Q35: Har gow wrapper flour
(137, 35, N'Wheat starch (cheng flour)',           1, 1, '2025-01-08 08:30:00'),
(138, 35, N'All-purpose plain flour',              0, 2, '2025-01-08 08:30:00'),
(139, 35, N'Rice flour',                           0, 3, '2025-01-08 08:30:00'),
(140, 35, N'Cornstarch only',                      0, 4, '2025-01-08 08:30:00'),
-- Q36: Wrapper thickness
(141, 36, N'Translucent, about 1–2 mm thick',      1, 1, '2025-01-08 08:30:00'),
(142, 36, N'About 5 mm thick for durability',      0, 2, '2025-01-08 08:30:00'),
(143, 36, N'As thick as fresh pasta dough',        0, 3, '2025-01-08 08:30:00'),
(144, 36, N'As thin as phyllo pastry',             0, 4, '2025-01-08 08:30:00'),
-- Q37: Har gow filling
(145, 37, N'Shrimp (prawns)',                      1, 1, '2025-01-08 08:30:00'),
(146, 37, N'Pork and shrimp mixed',                0, 2, '2025-01-08 08:30:00'),
(147, 37, N'Vegetables only',                      0, 3, '2025-01-08 08:30:00'),
(148, 37, N'Minced chicken',                       0, 4, '2025-01-08 08:30:00'),
-- Q38: Siu mai juiciness
(149, 38, N'Pork fat or diced water chestnuts',    1, 1, '2025-01-08 08:30:00'),
(150, 38, N'An egg yolk mixed in',                 0, 2, '2025-01-08 08:30:00'),
(151, 38, N'Cornstarch binder',                    0, 3, '2025-01-08 08:30:00'),
(152, 38, N'Soy sauce only',                       0, 4, '2025-01-08 08:30:00'),
-- Q39: Har gow pleats
(153, 39, N'Seven or more pleats on one side',     1, 1, '2025-01-08 08:30:00'),
(154, 39, N'Three pleats on each side',            0, 2, '2025-01-08 08:30:00'),
(155, 39, N'No pleats — just a pinched seal',      0, 3, '2025-01-08 08:30:00'),
(156, 39, N'Five pleats on both sides',            0, 4, '2025-01-08 08:30:00'),
-- Q40: Pleating motion
(157, 40, N'Push small folds of the back wrapper onto the front edge using the thumb', 1, 1, '2025-01-08 08:30:00'),
(158, 40, N'Pinch straight across the top edge',   0, 2, '2025-01-08 08:30:00'),
(159, 40, N'Twist the top closed like a purse',    0, 3, '2025-01-08 08:30:00'),
(160, 40, N'Fold flat like a pasty crimp',         0, 4, '2025-01-08 08:30:00'),
-- Q41: Steamer lining
(161, 41, N'Perforated baking paper or fresh cabbage leaves', 1, 1, '2025-01-08 08:30:00'),
(162, 41, N'Aluminium foil',                       0, 2, '2025-01-08 08:30:00'),
(163, 41, N'Damp cloth towels',                    0, 3, '2025-01-08 08:30:00'),
(164, 41, N'An oiled wire rack',                   0, 4, '2025-01-08 08:30:00'),
-- Q42: Water level in steamer
(165, 42, N'Enough to simmer steadily without touching the basket', 1, 1, '2025-01-08 08:30:00'),
(166, 42, N'Covering the basket completely',       0, 2, '2025-01-08 08:30:00'),
(167, 42, N'Just a small splash of water',         0, 3, '2025-01-08 08:30:00'),
(168, 42, N'The pot half-filled with boiling water',0, 4, '2025-01-08 08:30:00'),
-- Q43: Ramen style with milky broth
(169, 43, N'Tonkotsu',                             1, 1, '2024-11-12 09:45:00'),
(170, 43, N'Shoyu',                                0, 2, '2024-11-12 09:45:00'),
(171, 43, N'Shio',                                 0, 3, '2024-11-12 09:45:00'),
(172, 43, N'Miso',                                 0, 4, '2024-11-12 09:45:00'),
-- Q44: What is tare
(173, 44, N'A concentrated seasoning sauce added to each bowl before the broth', 1, 1, '2024-11-12 09:45:00'),
(174, 44, N'A type of alkaline noodle',            0, 2, '2024-11-12 09:45:00'),
(175, 44, N'A topping of pickled bamboo shoots',   0, 3, '2024-11-12 09:45:00'),
(176, 44, N'A technique for clarifying the broth', 0, 4, '2024-11-12 09:45:00'),
-- Q45: Tonkotsu simmering time
(177, 45, N'10–18 hours',                          1, 1, '2024-11-12 09:45:00'),
(178, 45, N'1–2 hours',                            0, 2, '2024-11-12 09:45:00'),
(179, 45, N'30 minutes',                           0, 3, '2024-11-12 09:45:00'),
(180, 45, N'3–4 hours',                            0, 4, '2024-11-12 09:45:00'),
-- Q46: Creamy white colour source
(181, 46, N'Collagen and fat emulsified out of pork bones by a vigorous boil', 1, 1, '2024-11-12 09:45:00'),
(182, 46, N'Milk added during cooking',            0, 2, '2024-11-12 09:45:00'),
(183, 46, N'White miso stirred in at the end',     0, 3, '2024-11-12 09:45:00'),
(184, 46, N'Rice flour used as a thickener',       0, 4, '2024-11-12 09:45:00'),
-- Q47: Noodle springiness ingredient
(185, 47, N'Kansui (alkaline water or lye water)',  1, 1, '2024-11-12 09:45:00'),
(186, 47, N'Egg yolk for colour',                  0, 2, '2024-11-12 09:45:00'),
(187, 47, N'Turmeric powder',                      0, 3, '2024-11-12 09:45:00'),
(188, 47, N'Baking soda dissolved in plain water', 0, 4, '2024-11-12 09:45:00'),
-- Q48: Noodle dough resting time
(189, 48, N'At least 30 minutes',                  1, 1, '2024-11-12 09:45:00'),
(190, 48, N'No resting is needed',                 0, 2, '2024-11-12 09:45:00'),
(191, 48, N'Just 5 minutes',                       0, 3, '2024-11-12 09:45:00'),
(192, 48, N'Overnight in the refrigerator',        0, 4, '2024-11-12 09:45:00'),
-- Q49: Chashu pork cut
(193, 49, N'Pork belly',                           1, 1, '2024-11-12 09:45:00'),
(194, 49, N'Pork loin',                            0, 2, '2024-11-12 09:45:00'),
(195, 49, N'Pork shoulder',                        0, 3, '2024-11-12 09:45:00'),
(196, 49, N'Pork ribs',                            0, 4, '2024-11-12 09:45:00'),
-- Q50: Ajitsuke tamago meaning
(197, 50, N'Seasoned or marinated egg',            1, 1, '2024-11-12 09:45:00'),
(198, 50, N'Soft-boiled egg',                      0, 2, '2024-11-12 09:45:00'),
(199, 50, N'Pickled egg',                          0, 3, '2024-11-12 09:45:00'),
(200, 50, N'Sweet custard egg',                    0, 4, '2024-11-12 09:45:00'),
-- Q51: Purpose of tare
(201, 51, N'To season each bowl individually for consistent flavour throughout service', 1, 1, '2024-11-12 09:45:00'),
(202, 51, N'To thicken the broth to the right viscosity',               0, 2, '2024-11-12 09:45:00'),
(203, 51, N'To add colour to the pale tonkotsu broth',                  0, 3, '2024-11-12 09:45:00'),
(204, 51, N'To balance the acidity of the noodles',                     0, 4, '2024-11-12 09:45:00'),
-- Q52: Aromatic finishing oil
(205, 52, N'Toasted sesame oil or garlic-infused oil',                  1, 1, '2024-11-12 09:45:00'),
(206, 52, N'Extra virgin olive oil',               0, 2, '2024-11-12 09:45:00'),
(207, 52, N'Plain vegetable oil',                  0, 3, '2024-11-12 09:45:00'),
(208, 52, N'Coconut oil',                          0, 4, '2024-11-12 09:45:00'),
-- Q53: Bowl assembly order
(209, 53, N'Tare first, then broth, then noodles, then toppings arranged on top', 1, 1, '2024-11-12 09:45:00'),
(210, 53, N'Noodles first, then broth poured over',0, 2, '2024-11-12 09:45:00'),
(211, 53, N'Toppings, then broth, then noodles',   0, 3, '2024-11-12 09:45:00'),
(212, 53, N'Broth, tare, noodles and toppings in any order',            0, 4, '2024-11-12 09:45:00'),
-- Q54: Topping that adds umami and crunch
(213, 54, N'Nori (dried seaweed) and menma (bamboo shoots)',            1, 1, '2024-11-12 09:45:00'),
(214, 54, N'Fresh lettuce leaves',                 0, 2, '2024-11-12 09:45:00'),
(215, 54, N'Melted cheese',                        0, 3, '2024-11-12 09:45:00'),
(216, 54, N'Crispy fried onion rings',             0, 4, '2024-11-12 09:45:00');
SET IDENTITY_INSERT Answers OFF;
GO

-- ============================================================
-- End of Database_02.sql
-- ============================================================
-- Quick row-count verification (run after seeding):
--   SELECT 'Users'               AS [Table], COUNT(*) AS [Rows] FROM Users
--   UNION ALL SELECT 'Cuisines',              COUNT(*) FROM Cuisines
--   UNION ALL SELECT 'Courses',               COUNT(*) FROM Courses
--   UNION ALL SELECT 'Chapters',              COUNT(*) FROM Chapters
--   UNION ALL SELECT 'Questions',             COUNT(*) FROM Questions
--   UNION ALL SELECT 'Answers',               COUNT(*) FROM Answers
--   UNION ALL SELECT 'Enrollments',           COUNT(*) FROM Enrollments
--   UNION ALL SELECT 'UserChapterProgress',   COUNT(*) FROM UserChapterProgress
--   UNION ALL SELECT 'QuizResults',           COUNT(*) FROM QuizResults
--   UNION ALL SELECT 'Comments',              COUNT(*) FROM Comments
--   UNION ALL SELECT 'SharerRegistrations',   COUNT(*) FROM SharerRegistrations
--   UNION ALL SELECT 'SharerRequests',        COUNT(*) FROM SharerRequests
--   UNION ALL SELECT 'ReportedContent',       COUNT(*) FROM ReportedContent
--   UNION ALL SELECT 'PlatformAnalytics',     COUNT(*) FROM PlatformAnalytics;
