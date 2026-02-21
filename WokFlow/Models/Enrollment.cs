using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace WokFlow.Models
{
    [Table("Enrollments")]
    public class Enrollment
    {
        [Key]
        public int EnrollmentId { get; set; }

        public int UserId { get; set; }

        public int CourseId { get; set; }

        public DateTime EnrollmentDate { get; set; }

        public int Progress { get; set; } // 0-100

        [Required, MaxLength(20)]
        public string Status { get; set; } // In Progress, Completed

        public DateTime CreatedAt { get; set; }

        public DateTime UpdatedAt { get; set; }

        [ForeignKey("UserId")]
        public virtual User User { get; set; } 

        [ForeignKey("CourseId")]
        public virtual Course Course { get; set; } 

        public virtual ICollection<UserChapterProgress> ChapterProgress { get; set; } = new HashSet<UserChapterProgress>();
    }
}
