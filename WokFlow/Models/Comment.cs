using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace WokFlow.Models
{
    [Table("Comments")]
    public class Comment
    {
        [Key]
        public int CommentId { get; set; }

        public int CourseId { get; set; }

        public int UserId { get; set; }

        [Required, MaxLength(2000)]
        public string CommentText { get; set; }

        public int Rating { get; set; } // 1-5

        public DateTime CreatedDate { get; set; }

        public DateTime CreatedAt { get; set; }

        public DateTime UpdatedAt { get; set; }

        [ForeignKey("CourseId")]
        public virtual Course Course { get; set; }

        [ForeignKey("UserId")]
        public virtual User User { get; set; }
    }
}
