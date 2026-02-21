using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace WokFlow.Models
{
    [Table("PlatformAnalytics")]
    public class PlatformAnalytics
    {
        [Key]
        public int AnalyticsId { get; set; }

        public DateTime RecordDate { get; set; }

        public int NewUsersCount { get; set; }

        public int TotalUsersCount { get; set; }

        public int ActiveCoursesCount { get; set; }

        public int TotalCoursesCount { get; set; }

        public DateTime CreatedAt { get; set; }
    }
}
