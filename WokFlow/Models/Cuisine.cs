using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace WokFlow.Models
{
    [Table("Cuisines")]
    public class Cuisine
    {
        [Key]
        public int CuisineId { get; set; }

        [Required, MaxLength(100)]
        public string CuisineName { get; set; } 

        [MaxLength(500)]
        public string Description { get; set; } 

        public DateTime CreatedAt { get; set; }

        public virtual ICollection<Course> Courses { get; set; } = new HashSet<Course>();
    }
}
