using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace WokFlow.Models
{
    [Table("QuizResults")]
    public class QuizResult
    {
        [Key]
        public int ResultId { get; set; }

        public int UserId { get; set; }

        public int ChapterId { get; set; }

        public int Score { get; set; }

        [Required, MaxLength(20)]
        public string Status { get; set; } // Passed, Failed

        public DateTime CompletedDate { get; set; }

        public DateTime CreatedAt { get; set; }

        [ForeignKey("UserId")]
        public virtual User User { get; set; }

        [ForeignKey("ChapterId")]
        public virtual Chapter Chapter { get; set; }
    }
}
