using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace WokFlow.Models
{
    [Table("Answers")]
    public class Answer
    {
        [Key]
        public int AnswerId { get; set; }

        public int QuestionId { get; set; }

        [Required, MaxLength(500)]
        public string AnswerText { get; set; }

        public bool IsCorrect { get; set; }

        public int AnswerOrder { get; set; }

        public DateTime CreatedAt { get; set; }

        [ForeignKey("QuestionId")]
        public virtual Question Question { get; set; } 
    }
}
