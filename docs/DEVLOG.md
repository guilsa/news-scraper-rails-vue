2025

Aug 14

Picking this back up from Thu Jan 5 00:09:30 2023. Current state of the repo as it was left is:

➜  news-scraper-rails-vue git:(frontend-stage-1) ✗ gst
On branch frontend-stage-1
Untracked files:
  (use "git add <file>..." to include in what will be committed)
        backend/lib/scraper_adapter/google_books.rb
        frontend/

Note I am in a `frontend-stage-1` branch.

Questions:
- Why is the frontend folder not yet added to version control? For one, it makes sense this was the scope of what I was working on, thus the branch name. So then the new question becomes why was I including a `backend/lib/scraper_adapter/google_books.rb` along with this? Perhaps the answer to this is that the backend repo was all the scraping (as a Rails worker in a Pi) and API service logic (in Heroku). I remember having that working. And never having a frontend for that, which is fine (all attention was going to understanding Rails, Rails delayed jobs, and a web API service really well). This actually checks. Looking inside the frontend folder, it's a brand new Vue scaffold. So IN CONCLUSION: the frontend changes is safe to trash and I can pick this up at any time. As per the backend/lib/scraper_adapter/google_books.rb logic, I remember getting side-tracked because I made a huge list of Pulitzer prize history books.

What google_books.rb is:
- Takes a non-clean list of book titles, without author, and calls Google Books API once per book, to try to get page count, author, date, and author gender. For every call, it updates a progress bar (plaintext). 
	- My reco: save the book list somewhere else (google spreadsheet), and trash the google_books.rb file. Or keep in a `google books scrape adapter` branch.

In conslusion how I am proceeding:
1. Add /docs/DEVLOG.md (these notes) to main branch
2. Trash the frontend folder. Not needed for now. Nothing important there.
3. Create and push new branch remote (`curated-books-data-enrichment`). Include backend/lib/scraper_adapter/google_books.rb.
4. Delete `frontend-stage-1` branch. No longer needed.