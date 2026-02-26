using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Web.Services.Description;


namespace WokFlow.Models
{
    public class Course
    {
        public int CourseId { get; set; }

        public string Title { get; set; }

        public string Description { get; set; }

        public int CuisineId { get; set; }

        public int CreatorId { get; set; }

        public string Duration { get; set; }

        public int Difficulty { get; set; } // 1 - 5

        public string ImageUrl { get; set; }

        public string Status { get; set; } // Active, Deleted, Banned

        public DateTime CreatedDate { get; set; }

        public DateTime CreatedAt { get; set; }

        public DateTime UpdatedAt { get; set; }

        // Foreign Key
        public virtual Cuisine Cuisine { get; set; }

        // Foreign Key
        public virtual User Creator { get; set; }

        public virtual ICollection<Chapter> Chapters { get; set; } = new HashSet<Chapter>();
        public virtual ICollection<Enrollment> Enrollments { get; set; } = new HashSet<Enrollment>();
        public virtual ICollection<Comment> Comments { get; set; } = new HashSet<Comment>();
    }
}
