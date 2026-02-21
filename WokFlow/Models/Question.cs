using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace WokFlow.Models
{
    [Table("Questions")]
    public class Question
    {
        [Key]
        public int QuestionId { get; set; }

        public int ChapterId { get; set; }

        [Required, MaxLength(1000)]
        public string QuestionText { get; set; }

        public int QuestionOrder { get; set; }

        public DateTime CreatedAt { get; set; }

        public DateTime UpdatedAt { get; set; }

        [ForeignKey("ChapterId")]
        public virtual Chapter Chapter { get; set; }

        public virtual ICollection<Answer> Answers { get; set; } = new HashSet<Answer>();
    }
}
