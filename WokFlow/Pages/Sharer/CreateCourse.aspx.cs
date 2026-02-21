using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using WokFlow.Models;

namespace WokFlow.Pages.Sharer
{
    [Serializable]
    public class AnswerEntry
    {
        public string Text { get; set; } = "";
        public bool IsCorrect { get; set; }
    }

    [Serializable]
    public class QuestionEntry
    {
        public string QuestionText { get; set; } = "";
        public List<AnswerEntry> Answers { get; set; } = new List<AnswerEntry>();
    }

    [Serializable]
    public class ChapterEntry
    {
        public string Title { get; set; } = "";
        public string Description { get; set; } = "";
        public string VideoUrl { get; set; } = "";
        public QuestionEntry Question { get; set; } = new QuestionEntry();
    }

    public partial class CreateCoursePage : SharerPage
    {
        protected int CurrentStep
        {
            get { return ViewState["Step"] != null ? (int)ViewState["Step"] : 1; }
            set { ViewState["Step"] = value; }
        }

        protected bool IsEditing
        {
            get { return !string.IsNullOrEmpty(Request.QueryString["editId"]); }
        }

        // Stores the uploaded image path between Step 1 → Step 2 postbacks
        private string TempImagePath
        {
            get { return ViewState["TempImagePath"] as string; }
            set { ViewState["TempImagePath"] = value; }
        }

        private List<ChapterEntry> ChapterList
        {
            get { return ViewState["Chapters"] as List<ChapterEntry> ?? new List<ChapterEntry>(); }
            set { ViewState["Chapters"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (IsEditing)
                    LoadCourseForEdit();
            }
        }

        private void LoadCourseForEdit()
        {
            int editId = int.Parse(Request.QueryString["editId"]);
            using (var db = new WokFlowContext())
            {
                var course = db.Courses.Find(editId);
                if (course == null || course.CreatorId != CurrentUserId) return;

                txtTitle.Text = course.Title;
                txtDescription.Text = course.Description;
                ddlCuisine.SelectedValue = course.CuisineId.ToString();
                ddlDifficulty.SelectedValue = course.Difficulty.ToString();
                txtDuration.Text = course.Duration;

                if (!string.IsNullOrEmpty(course.ImageUrl))
                {
                    lblCurrentImage.Text = "Current image: " + course.ImageUrl;
                    lblCurrentImage.Visible = true;
                    TempImagePath = course.ImageUrl; // keep existing image unless replaced
                }

                // Load chapters with video and quiz data
                var chapterData = db.Chapters
                    .Where(ch => ch.CourseId == editId)
                    .OrderBy(ch => ch.ChapterOrder)
                    .ToList();

                var entries = new List<ChapterEntry>();
                foreach (var ch in chapterData)
                {
                    var entry = new ChapterEntry
                    {
                        Title = ch.Title,
                        Description = ch.Description,
                        VideoUrl = ch.VideoUrl ?? ""
                    };

                    var firstQ = db.Questions.FirstOrDefault(q => q.ChapterId == ch.ChapterId);
                    if (firstQ != null)
                    {
                        var answers = db.Answers
                            .Where(a => a.QuestionId == firstQ.QuestionId)
                            .OrderBy(a => a.AnswerOrder)
                            .ToList();

                        entry.Question = new QuestionEntry
                        {
                            QuestionText = firstQ.QuestionText,
                            Answers = answers.Select(a => new AnswerEntry
                            {
                                Text = a.AnswerText,
                                IsCorrect = a.IsCorrect
                            }).ToList()
                        };
                    }

                    entries.Add(entry);
                }

                ChapterList = entries;
                rptChapters.DataSource = entries;
                rptChapters.DataBind();
            }
        }

        // ── Step Navigation ────────────────────────────────────────────────────
        protected void btnNext_Click(object sender, EventArgs e)
        {
            // Upload image NOW while the file data is still available (multi-step form limitation)
            if (fuCourseImage.HasFile)
            {
                string uploadDir = Server.MapPath("~/Images/courses/");
                if (!Directory.Exists(uploadDir))
                    Directory.CreateDirectory(uploadDir);

                string safeFileName = DateTime.UtcNow.Ticks + "_" +
                    Path.GetFileName(fuCourseImage.FileName);
                fuCourseImage.SaveAs(Path.Combine(uploadDir, safeFileName));
                TempImagePath = "/Images/courses/" + safeFileName;
            }

            CurrentStep = 2;
            pnlStep1.Visible = false;
            pnlStep2.Visible = true;
            rptChapters.DataSource = ChapterList;
            rptChapters.DataBind();
        }

        protected void btnBack_Click(object sender, EventArgs e)
        {
            CurrentStep = 1;
            pnlStep1.Visible = true;
            pnlStep2.Visible = false;
        }

        // ── Add Chapter ────────────────────────────────────────────────────────
        protected void btnAddChapter_Click(object sender, EventArgs e)
        {
            string title = txtChapterTitle.Text.Trim();
            if (string.IsNullOrEmpty(title)) return;

            int correctIdx = int.Parse(ddlCorrectAnswer.SelectedValue) - 1;
            var answerTexts = new[]
            {
                txtAnswer1.Text.Trim(),
                txtAnswer2.Text.Trim(),
                txtAnswer3.Text.Trim(),
                txtAnswer4.Text.Trim()
            };

            var entry = new ChapterEntry
            {
                Title = title,
                Description = txtChapterDescription.Text.Trim(),
                VideoUrl = txtVideoUrl.Text.Trim(),
                Question = new QuestionEntry
                {
                    QuestionText = txtQuestionText.Text.Trim(),
                    Answers = answerTexts.Select((text, i) => new AnswerEntry
                    {
                        Text = text,
                        IsCorrect = i == correctIdx
                    }).ToList()
                }
            };

            var chapters = ChapterList;
            chapters.Add(entry);
            ChapterList = chapters;

            // Clear inputs
            txtChapterTitle.Text = "";
            txtChapterDescription.Text = "";
            txtVideoUrl.Text = "";
            txtQuestionText.Text = "";
            txtAnswer1.Text = txtAnswer2.Text = txtAnswer3.Text = txtAnswer4.Text = "";
            ddlCorrectAnswer.SelectedIndex = 0;

            rptChapters.DataSource = chapters;
            rptChapters.DataBind();
        }

        // ── Save Course ────────────────────────────────────────────────────────
        protected void btnSaveCourse_Click(object sender, EventArgs e)
        {
            using (var db = new WokFlowContext())
            {
                Course course;
                bool isNew = !IsEditing;

                if (IsEditing)
                {
                    int editId = int.Parse(Request.QueryString["editId"]);
                    course = db.Courses.Find(editId);
                    if (course == null || course.CreatorId != CurrentUserId) return;
                }
                else
                {
                    course = new Course
                    {
                        CreatorId = CurrentUserId,
                        Status = "Active",
                        CreatedDate = DateTime.UtcNow,
                        CreatedAt = DateTime.UtcNow
                    };
                    db.Courses.Add(course);
                }

                course.Title = txtTitle.Text.Trim();
                course.Description = txtDescription.Text.Trim();
                course.CuisineId = int.Parse(ddlCuisine.SelectedValue);
                course.Difficulty = int.Parse(ddlDifficulty.SelectedValue);
                course.Duration = txtDuration.Text.Trim();
                course.UpdatedAt = DateTime.UtcNow;

                // Apply uploaded image path (saved during btnNext_Click)
                if (!string.IsNullOrEmpty(TempImagePath))
                    course.ImageUrl = TempImagePath;

                db.SaveChanges();

                // For editing: remove all old chapters, questions, answers first
                if (IsEditing)
                {
                    var oldChapters = db.Chapters.Where(ch => ch.CourseId == course.CourseId).ToList();
                    foreach (var ch in oldChapters)
                    {
                        var oldQs = db.Questions.Where(q => q.ChapterId == ch.ChapterId).ToList();
                        foreach (var q in oldQs)
                            db.Answers.RemoveRange(db.Answers.Where(a => a.QuestionId == q.QuestionId));
                        db.Questions.RemoveRange(oldQs);

                        var oldProgress = db.UserChapterProgress.Where(p => p.ChapterId == ch.ChapterId);
                        db.UserChapterProgress.RemoveRange(oldProgress);
                    }
                    db.Chapters.RemoveRange(oldChapters);
                    db.SaveChanges();
                }

                // Save chapters, videos, questions and answers
                var chapters = ChapterList;
                for (int i = 0; i < chapters.Count; i++)
                {
                    var ch = new Chapter
                    {
                        CourseId = course.CourseId,
                        ChapterOrder = i + 1,
                        Title = chapters[i].Title,
                        Description = chapters[i].Description,
                        VideoUrl = chapters[i].VideoUrl ?? "",
                        CreatedAt = DateTime.UtcNow,
                        UpdatedAt = DateTime.UtcNow
                    };
                    db.Chapters.Add(ch);
                    db.SaveChanges(); // flush to get ChapterId

                    var qEntry = chapters[i].Question;
                    if (qEntry != null && !string.IsNullOrEmpty(qEntry.QuestionText))
                    {
                        var question = new Question
                        {
                            ChapterId = ch.ChapterId,
                            QuestionText = qEntry.QuestionText,
                            QuestionOrder = 1,
                            CreatedAt = DateTime.UtcNow,
                            UpdatedAt = DateTime.UtcNow
                        };
                        db.Questions.Add(question);
                        db.SaveChanges(); // flush to get QuestionId

                        for (int j = 0; j < qEntry.Answers.Count; j++)
                        {
                            db.Answers.Add(new Answer
                            {
                                QuestionId = question.QuestionId,
                                AnswerText = qEntry.Answers[j].Text,
                                IsCorrect = qEntry.Answers[j].IsCorrect,
                                AnswerOrder = j + 1,
                                CreatedAt = DateTime.UtcNow
                            });
                        }
                        db.SaveChanges();
                    }
                }

                Response.Redirect("~/Pages/Shared/MyCourses.aspx?tab=created");
            }
        }

        // ── View Helpers ───────────────────────────────────────────────────────
        protected string GetQuizPreview(object questionObj)
        {
            var q = questionObj as QuestionEntry;
            if (q == null || string.IsNullOrEmpty(q.QuestionText))
                return "<span class='text-gray-400'>No quiz</span>";

            string preview = q.QuestionText.Length > 50
                ? q.QuestionText.Substring(0, 50) + "..."
                : q.QuestionText;
            return "<span class='text-green-600 font-medium'>Quiz: </span>" +
                   HttpUtility.HtmlEncode(preview);
        }
    }
}