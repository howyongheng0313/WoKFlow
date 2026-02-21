using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace WokFlow.Models
{
    [Table("ReportedContent")]
    public class ReportedContent
    {
        [Key]
        public int ReportId { get; set; }

        public int CourseId { get; set; }

        public int ReporterId { get; set; }

        [Required, MaxLength(1000)]
        public string Reason { get; set; } 

        public DateTime ReportDate { get; set; }

        [Required, MaxLength(20)]
        public string Status { get; set; } // Pending, Ignored, Banned

        public int? ReviewedBy { get; set; }

        public DateTime? ReviewedDate { get; set; }

        public DateTime CreatedAt { get; set; }

        public DateTime UpdatedAt { get; set; }

        [ForeignKey("CourseId")]
        public virtual Course Course { get; set; } 

        [ForeignKey("ReporterId")]
        public virtual User Reporter { get; set; } 
    }
}
