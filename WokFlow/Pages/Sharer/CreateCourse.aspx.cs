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
        public string Title { get; set; } = "Untitled Chapter";
        public string Description { get; set; } = "";
        public string VideoUrl { get; set; } = "";
        public List<QuestionEntry> Questions { get; set; } = new List<QuestionEntry>();
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

        protected int ChapterCount
        {
            get { return ChapterList.Count; }
        }

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

        private int SelectedChapterIndex
        {
            get { return ViewState["SelectedChapterIdx"] != null ? (int)ViewState["SelectedChapterIdx"] : 0; }
            set { ViewState["SelectedChapterIdx"] = value; }
        }

        private int CurrentQuestionIndex
        {
            get { return ViewState["CurrentQIdx"] != null ? (int)ViewState["CurrentQIdx"] : 0; }
            set { ViewState["CurrentQIdx"] = value; }
        }

        // =====================================================================
        // Page Lifecycle
        // =====================================================================

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (IsEditing) LoadCourseForEdit();
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
                hdnDifficulty.Value = course.Difficulty.ToString();
                txtDuration.Text = course.Duration;

                if (!string.IsNullOrEmpty(course.ImageUrl))
                {
                    lblCurrentImage.Text = "Current image: " + course.ImageUrl;
                    lblCurrentImage.Visible = true;
                    TempImagePath = course.ImageUrl;
                }

                // Load chapters with ALL questions
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

                    var allQs = db.Questions
                        .Where(q => q.ChapterId == ch.ChapterId)
                        .OrderBy(q => q.QuestionOrder)
                        .ToList();

                    foreach (var dbQ in allQs)
                    {
                        var answers = db.Answers
                            .Where(a => a.QuestionId == dbQ.QuestionId)
                            .OrderBy(a => a.AnswerOrder)
                            .ToList();

                        entry.Questions.Add(new QuestionEntry
                        {
                            QuestionText = dbQ.QuestionText,
                            Answers = answers.Select(a => new AnswerEntry
                            {
                                Text = a.AnswerText,
                                IsCorrect = a.IsCorrect
                            }).ToList()
                        });
                    }

                    entries.Add(entry);
                }

                ChapterList = entries;
                SelectedChapterIndex = 0;
                CurrentQuestionIndex = 0;
            }
        }

        // =====================================================================
        // Step 1 Validation
        // =====================================================================

        private bool ValidateStep1(out string errorMessage)
        {
            var errors = new List<string>();

            if (string.IsNullOrWhiteSpace(txtTitle.Text))
                errors.Add("Course title is required.");

            if (string.IsNullOrWhiteSpace(txtDescription.Text))
                errors.Add("Course description is required.");

            if (string.IsNullOrEmpty(ddlCuisine.SelectedValue))
                errors.Add("Please select a cuisine type.");

            int difficulty;
            if (!int.TryParse(hdnDifficulty.Value, out difficulty) || difficulty < 1 || difficulty > 5)
                errors.Add("Please select a difficulty rating (1-5).");

            if (string.IsNullOrWhiteSpace(txtDuration.Text))
                errors.Add("Course duration is required.");

            bool hasNewImage = fuCourseImage.HasFile;
            bool hasExistingImage = !string.IsNullOrEmpty(TempImagePath);

            if (!hasNewImage && !hasExistingImage)
            {
                errors.Add("Please upload a course image.");
            }
            else if (hasNewImage)
            {
                string ext = Path.GetExtension(fuCourseImage.FileName).ToLowerInvariant();
                if (ext != ".jpg" && ext != ".jpeg" && ext != ".png")
                    errors.Add("Course image must be a JPG or PNG file.");

                if (fuCourseImage.PostedFile.ContentLength > 10 * 1024 * 1024)
                    errors.Add("Course image must be 10 MB or smaller.");
            }

            errorMessage = string.Join("<br/>", errors);
            return errors.Count == 0;
        }

        // =====================================================================
        // Step Navigation
        // =====================================================================

        protected void btnNext_Click(object sender, EventArgs e)
        {
            string validationError;
            if (!ValidateStep1(out validationError))
            {
                lblStep1Error.Text = validationError;
                lblStep1Error.Visible = true;
                return;
            }

            lblStep1Error.Visible = false;

            // Upload image NOW while the file data is still available
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

            // Seed one default chapter on first visit to Step 2
            if (ChapterList.Count == 0)
            {
                var chapters = new List<ChapterEntry> { new ChapterEntry() };
                ChapterList = chapters;
                SelectedChapterIndex = 0;
                CurrentQuestionIndex = 0;
            }

            LoadChapterIntoForm(SelectedChapterIndex);
            BindStep2();
        }

        protected void btnBack_Click(object sender, EventArgs e)
        {
            SaveCurrentFormToChapter();
            CurrentStep = 1;
            pnlStep1.Visible = true;
            pnlStep2.Visible = false;
        }

        // =====================================================================
        // Helper Methods
        // =====================================================================

        private void SaveCurrentFormToChapter()
        {
            var chapters = ChapterList;
            if (chapters.Count == 0) return;

            int idx = SelectedChapterIndex;
            if (idx < 0 || idx >= chapters.Count) return;

            string title = txtChapterTitle.Text.Trim();
            chapters[idx].Title = string.IsNullOrEmpty(title) ? "Untitled Chapter" : title;
            chapters[idx].Description = txtChapterDescription.Text.Trim();
            // Handle video file upload
            if (fuChapterVideo.HasFile)
            {
                string uploadDir = Server.MapPath("~/Videos/chapters/");
                if (!Directory.Exists(uploadDir))
                    Directory.CreateDirectory(uploadDir);

                string safeFileName = DateTime.UtcNow.Ticks + "_" +
                    Path.GetFileName(fuChapterVideo.FileName);
                fuChapterVideo.SaveAs(Path.Combine(uploadDir, safeFileName));
                chapters[idx].VideoUrl = "/Videos/chapters/" + safeFileName;
            }

            ChapterList = chapters;
        }

        private void LoadChapterIntoForm(int index)
        {
            var chapters = ChapterList;
            if (chapters.Count == 0) return;
            if (index < 0 || index >= chapters.Count) index = 0;

            var ch = chapters[index];
            txtChapterTitle.Text = ch.Title == "Untitled Chapter" ? "" : ch.Title;
            txtChapterDescription.Text = ch.Description;
        }

        private void BindStep2()
        {
            var chapters = ChapterList;
            int selIdx = SelectedChapterIndex;

            // Clamp selection
            if (selIdx >= chapters.Count && chapters.Count > 0)
            {
                selIdx = chapters.Count - 1;
                SelectedChapterIndex = selIdx;
            }

            // Bind chapter card list with selection state
            rptChapters.DataSource = chapters.Select((ch, i) => new
            {
                Title = string.IsNullOrEmpty(ch.Title) ? "Untitled Chapter" : ch.Title,
                IsSelected = (i == selIdx),
                Index = i
            }).ToList();
            rptChapters.DataBind();

            // Quiz header label
            string selTitle = chapters.Count > 0
                ? (string.IsNullOrEmpty(chapters[selIdx].Title) ? "Untitled Chapter" : chapters[selIdx].Title)
                : "Untitled Chapter";
            lblQuizChapter.Text = selTitle;

            // Quiz question display
            if (chapters.Count == 0)
            {
                pnlNoQuestions.Visible = true;
                pnlQuizQuestions.Visible = false;
                pnlQuizPagination.Visible = false;
                return;
            }

            var questions = chapters[selIdx].Questions;
            if (questions == null || questions.Count == 0)
            {
                pnlNoQuestions.Visible = true;
                pnlQuizQuestions.Visible = false;
                pnlQuizPagination.Visible = false;
                return;
            }

            pnlNoQuestions.Visible = false;
            pnlQuizQuestions.Visible = true;
            pnlQuizPagination.Visible = true;

            int qIdx = CurrentQuestionIndex;
            if (qIdx >= questions.Count) qIdx = questions.Count - 1;
            if (qIdx < 0) qIdx = 0;
            CurrentQuestionIndex = qIdx;

            var currentQ = questions[qIdx];

            // Populate question form with current question data
            txtQuestionText.Text = currentQ.QuestionText;
            txtAnswer1.Text = currentQ.Answers.Count > 0 ? currentQ.Answers[0].Text : "";
            txtAnswer2.Text = currentQ.Answers.Count > 1 ? currentQ.Answers[1].Text : "";
            txtAnswer3.Text = currentQ.Answers.Count > 2 ? currentQ.Answers[2].Text : "";
            txtAnswer4.Text = currentQ.Answers.Count > 3 ? currentQ.Answers[3].Text : "";

            int correctIdx = currentQ.Answers.FindIndex(a => a.IsCorrect);
            hdnCorrectAnswer.Value = correctIdx >= 0 ? correctIdx.ToString() : "0";

            // Pagination label
            lblQuestionPager.Text = string.Format("Question {0} of {1}", qIdx + 1, questions.Count);

            // Prev/Next states
            btnPrevQuestion.Enabled = (qIdx > 0);
            btnNextQuestion.Enabled = (qIdx < questions.Count - 1);
        }

        // =====================================================================
        // Chapter Event Handlers
        // =====================================================================

        protected void rptChapters_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "SelectChapter")
            {
                SaveCurrentQuestionToChapter();
                SaveCurrentFormToChapter();

                int idx = int.Parse(e.CommandArgument.ToString());
                SelectedChapterIndex = idx;
                CurrentQuestionIndex = 0;

                LoadChapterIntoForm(idx);
                BindStep2();
            }
        }

        protected void btnAddChapter_Click(object sender, EventArgs e)
        {
            SaveCurrentQuestionToChapter();
            SaveCurrentFormToChapter();

            var chapters = ChapterList;
            chapters.Add(new ChapterEntry());
            ChapterList = chapters;

            int newIdx = chapters.Count - 1;
            SelectedChapterIndex = newIdx;
            CurrentQuestionIndex = 0;

            // Clear form for new blank chapter
            txtChapterTitle.Text = "";
            txtChapterDescription.Text = "";

            // Clear question form
            txtQuestionText.Text = "";
            txtAnswer1.Text = txtAnswer2.Text = txtAnswer3.Text = txtAnswer4.Text = "";
            hdnCorrectAnswer.Value = "0";

            BindStep2();
        }

        // =====================================================================
        // Quiz Event Handlers
        // =====================================================================

        private void SaveCurrentQuestionToChapter()
        {
            var chapters = ChapterList;
            if (chapters.Count == 0) return;

            int chIdx = SelectedChapterIndex;
            if (chIdx < 0 || chIdx >= chapters.Count) return;

            var questions = chapters[chIdx].Questions;
            int qIdx = CurrentQuestionIndex;
            if (questions.Count == 0 || qIdx < 0 || qIdx >= questions.Count) return;

            // Update the current question with form values
            int correctIdx = 0;
            int.TryParse(hdnCorrectAnswer.Value, out correctIdx);

            var answerTexts = new[]
            {
                txtAnswer1.Text.Trim(),
                txtAnswer2.Text.Trim(),
                txtAnswer3.Text.Trim(),
                txtAnswer4.Text.Trim()
            };

            questions[qIdx].QuestionText = txtQuestionText.Text.Trim();
            questions[qIdx].Answers = answerTexts.Select((text, i) => new AnswerEntry
            {
                Text = text,
                IsCorrect = (i == correctIdx)
            }).ToList();

            ChapterList = chapters;
        }

        protected void btnAddQuestion_Click(object sender, EventArgs e)
        {
            // Save current question edits first
            SaveCurrentQuestionToChapter();
            SaveCurrentFormToChapter();

            var chapters = ChapterList;
            int chIdx = SelectedChapterIndex;

            // Create a new blank question
            var newQ = new QuestionEntry
            {
                QuestionText = "",
                Answers = new List<AnswerEntry>
                {
                    new AnswerEntry { Text = "", IsCorrect = true },
                    new AnswerEntry { Text = "", IsCorrect = false },
                    new AnswerEntry { Text = "", IsCorrect = false },
                    new AnswerEntry { Text = "", IsCorrect = false }
                }
            };

            chapters[chIdx].Questions.Add(newQ);
            ChapterList = chapters;

            // Navigate to the new question
            CurrentQuestionIndex = chapters[chIdx].Questions.Count - 1;

            // Clear question form for new entry
            txtQuestionText.Text = "";
            txtAnswer1.Text = txtAnswer2.Text = txtAnswer3.Text = txtAnswer4.Text = "";
            hdnCorrectAnswer.Value = "0";

            BindStep2();
        }

        protected void btnDeleteQuestion_Click(object sender, EventArgs e)
        {
            var chapters = ChapterList;
            int chIdx = SelectedChapterIndex;
            int qIdx = CurrentQuestionIndex;

            if (chapters[chIdx].Questions.Count == 0) return;

            chapters[chIdx].Questions.RemoveAt(qIdx);
            ChapterList = chapters;

            // Clamp index
            int newCount = chapters[chIdx].Questions.Count;
            if (CurrentQuestionIndex >= newCount && newCount > 0)
                CurrentQuestionIndex = newCount - 1;
            else if (newCount == 0)
                CurrentQuestionIndex = 0;

            // Clear form if no questions remain
            if (newCount == 0)
            {
                txtQuestionText.Text = "";
                txtAnswer1.Text = txtAnswer2.Text = txtAnswer3.Text = txtAnswer4.Text = "";
                hdnCorrectAnswer.Value = "0";
            }

            BindStep2();
        }

        protected void btnPrevQuestion_Click(object sender, EventArgs e)
        {
            SaveCurrentQuestionToChapter();
            if (CurrentQuestionIndex > 0)
                CurrentQuestionIndex--;
            BindStep2();
        }

        protected void btnNextQuestion_Click(object sender, EventArgs e)
        {
            SaveCurrentQuestionToChapter();
            var chapters = ChapterList;
            int maxIdx = chapters[SelectedChapterIndex].Questions.Count - 1;
            if (CurrentQuestionIndex < maxIdx)
                CurrentQuestionIndex++;
            BindStep2();
        }

        // =====================================================================
        // Save Course
        // =====================================================================

        protected void btnSaveCourse_Click(object sender, EventArgs e)
        {
            SaveCurrentQuestionToChapter();
            SaveCurrentFormToChapter();

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

                int cuisineId;
                if (int.TryParse(ddlCuisine.SelectedValue, out cuisineId))
                    course.CuisineId = cuisineId;

                int difficulty;
                if (int.TryParse(hdnDifficulty.Value, out difficulty))
                    course.Difficulty = difficulty;
                else
                    course.Difficulty = 1;

                course.Duration = txtDuration.Text.Trim();
                course.UpdatedAt = DateTime.UtcNow;

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

                // Save chapters with multiple questions each
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

                    var questionList = chapters[i].Questions ?? new List<QuestionEntry>();
                    for (int q = 0; q < questionList.Count; q++)
                    {
                        var qEntry = questionList[q];
                        if (string.IsNullOrEmpty(qEntry.QuestionText)) continue;

                        var question = new Question
                        {
                            ChapterId = ch.ChapterId,
                            QuestionText = qEntry.QuestionText,
                            QuestionOrder = q + 1,
                            CreatedAt = DateTime.UtcNow,
                            UpdatedAt = DateTime.UtcNow
                        };
                        db.Questions.Add(question);
                        db.SaveChanges(); // flush to get QuestionId

                        for (int a = 0; a < qEntry.Answers.Count; a++)
                        {
                            db.Answers.Add(new Answer
                            {
                                QuestionId = question.QuestionId,
                                AnswerText = qEntry.Answers[a].Text,
                                IsCorrect = qEntry.Answers[a].IsCorrect,
                                AnswerOrder = a + 1,
                                CreatedAt = DateTime.UtcNow
                            });
                        }
                        db.SaveChanges();
                    }
                }

                Response.Redirect("~/Pages/Shared/MyCourses.aspx?tab=created");
            }
        }
    }
}