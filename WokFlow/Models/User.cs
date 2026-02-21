using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace WokFlow.Models
{
    [Table("Users")]
    public class User
    {
        [Key]
        public int UserId { get; set; }

        [Required, MaxLength(100)]
        public string Username { get; set; }

        [Required, MaxLength(255)]
        public string Email { get; set; }

        [Required, MaxLength(255)]
        public string PasswordHash { get; set; }

        [Required, MaxLength(20)]
        public string Role { get; set; } // GUEST, LEARNER, SHARER, ADMIN

        [Required, MaxLength(20)]
        public string Status { get; set; } // Active, Banned

        public DateTime? BirthDate { get; set; }

        [MaxLength(100)]
        public string Country { get; set; }

        public DateTime JoinedDate { get; set; }

        public DateTime CreatedAt { get; set; }

        public DateTime UpdatedAt { get; set; }

        public virtual ICollection<Course> CreatedCourses { get; set; } = new HashSet<Course>();
        public virtual ICollection<Enrollment> Enrollments { get; set; } = new HashSet<Enrollment>();
        public virtual ICollection<Comment> Comments { get; set; } = new HashSet<Comment>();
        public virtual ICollection<QuizResult> QuizResults { get; set; } = new HashSet<QuizResult>();
        public virtual ICollection<UserChapterProgress> ChapterProgress { get; set; } = new HashSet<UserChapterProgress>();
    }
}
