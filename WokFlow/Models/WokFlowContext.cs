using System.Data.Entity;

namespace WokFlow.Models
{
    public class WokFlowContext : DbContext
    {
        public WokFlowContext() : base("name=WokFlowContext")
        {
            // Database.SetInitializer(new MigrateDatabaseToLatestVersion<WokFlowContext, Migrations.Configuration>());
        }

        public DbSet<User> Users { get; set; }
        public DbSet<Cuisine> Cuisines { get; set; }
        public DbSet<Course> Courses { get; set; }
        public DbSet<Chapter> Chapters { get; set; }
        public DbSet<Question> Questions { get; set; }
        public DbSet<Answer> Answers { get; set; }
        public DbSet<Enrollment> Enrollments { get; set; }
        public DbSet<QuizResult> QuizResults { get; set; }
        public DbSet<Comment> Comments { get; set; }
        public DbSet<SharerRegistration> SharerRegistrations { get; set; }
        public DbSet<ReportedContent> ReportedContents { get; set; }
        public DbSet<PlatformAnalytics> PlatformAnalytics { get; set; }
        public DbSet<UserChapterProgress> UserChapterProgress { get; set; }

        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            // Prevent cascade delete cycles
            modelBuilder.Entity<Course>()
                .HasRequired(c => c.Creator)
                .WithMany(u => u.CreatedCourses)
                .HasForeignKey(c => c.CreatorId)
                .WillCascadeOnDelete(false);

            modelBuilder.Entity<Comment>()
                .HasRequired(c => c.User)
                .WithMany(u => u.Comments)
                .HasForeignKey(c => c.UserId)
                .WillCascadeOnDelete(false);

            modelBuilder.Entity<ReportedContent>()
                .HasRequired(r => r.Reporter)
                .WithMany()
                .HasForeignKey(r => r.ReporterId)
                .WillCascadeOnDelete(false);

            modelBuilder.Entity<ReportedContent>()
                .HasRequired(r => r.Course)
                .WithMany()
                .HasForeignKey(r => r.CourseId)
                .WillCascadeOnDelete(false);

            modelBuilder.Entity<QuizResult>()
                .HasRequired(q => q.User)
                .WithMany(u => u.QuizResults)
                .HasForeignKey(q => q.UserId)
                .WillCascadeOnDelete(false);

            modelBuilder.Entity<UserChapterProgress>()
                .HasRequired(p => p.User)
                .WithMany(u => u.ChapterProgress)
                .HasForeignKey(p => p.UserId)
                .WillCascadeOnDelete(false);

            modelBuilder.Entity<UserChapterProgress>()
                .HasRequired(p => p.Enrollment)
                .WithMany(e => e.ChapterProgress)
                .HasForeignKey(p => p.EnrollmentId)
                .WillCascadeOnDelete(false);

            base.OnModelCreating(modelBuilder);
        }
    }
}
