using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Web.Services.Description;


namespace WokFlow.Models
{
    [Table("Courses")]
    public class Course
    {
        [Key]
        public int CourseId { get; set; }

        [Required, MaxLength(200)]
        public string Title { get; set; }

        [MaxLength(2000)]
        public string Description { get; set; }

        public int CuisineId { get; set; }

        public int CreatorId { get; set; }

        [MaxLength(50)]
        public string Duration { get; set; }

        public int Difficulty { get; set; } // 1-5

        [MaxLength(500)]
        public string ImageUrl { get; set; }

        [Required, MaxLength(20)]
        public string Status { get; set; } // Active, Deleted

        public DateTime CreatedDate { get; set; }

        public DateTime CreatedAt { get; set; }

        public DateTime UpdatedAt { get; set; }

        [ForeignKey("CuisineId")]
        public virtual Cuisine Cuisine { get; set; }

        [ForeignKey("CreatorId")]
        public virtual User Creator { get; set; }

        public virtual ICollection<Chapter> Chapters { get; set; } = new HashSet<Chapter>();
        public virtual ICollection<Enrollment> Enrollments { get; set; } = new HashSet<Enrollment>();
        public virtual ICollection<Comment> Comments { get; set; } = new HashSet<Comment>();
    }
}
