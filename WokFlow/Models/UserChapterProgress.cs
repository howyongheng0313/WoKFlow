using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace WokFlow.Models
{
    [Table("UserChapterProgress")]
    public class UserChapterProgress
    {
        [Key]
        public int ProgressId { get; set; }

        public int UserId { get; set; }

        public int EnrollmentId { get; set; }

        public int ChapterId { get; set; }

        public bool IsCompleted { get; set; }

        public DateTime? CompletedDate { get; set; }

        public DateTime CreatedAt { get; set; }

        public DateTime UpdatedAt { get; set; }

        [ForeignKey("UserId")]
        public virtual User User { get; set; } 

        [ForeignKey("EnrollmentId")]
        public virtual Enrollment Enrollment { get; set; } 

        [ForeignKey("ChapterId")]
        public virtual Chapter Chapter { get; set; } 
    }
}
