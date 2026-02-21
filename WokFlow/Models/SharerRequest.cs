using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace WokFlow.Models
{
    [Table("SharerRequests")]
    public class SharerRequest
    {
        [Key]
        public int RequestId { get; set; }

        public int UserId { get; set; }

        public DateTime RequestDate { get; set; }

        [Required, MaxLength(20)]
        public string Status { get; set; } // Pending, Accepted, Rejected

        public int? ReviewedBy { get; set; }

        public DateTime? ReviewedDate { get; set; }

        public DateTime CreatedAt { get; set; }

        public DateTime UpdatedAt { get; set; }

        [ForeignKey("UserId")]
        public virtual User User { get; set; }
    }
}
