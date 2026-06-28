# Timbre Automation Blueprint — Niche-by-Niche

A 9-year-old could set these up. Here's exactly how.

---

## How to Read This Guide

Every automation has the same format:

> **WHAT IT DOES** — One sentence
> **TRIGGER** — What starts it
> **STEPS** — What it does, in order
> **SETUP TIME** — 5 minutes or 15 minutes
> **HOW TO SET IT UP** — Exact instructions

**One rule:** Every `[bracket]` is where you paste your own API key, email, or link. Fill in the brackets.

---

# REAL ESTATE

## Automation 1 — New Lead Auto-Responder

**WHAT IT DOES:** When someone fills out a contact form on a real estate website, it automatically texts them back and adds them to the CRM within 30 seconds.

**TRIGGER:** Someone submits a form on the real estate website (Zillow, Realtor, or their own site)

**STEPS:**
1. Form submission hits n8n webhook
2. Save contact info to Google Sheet (name, phone, email, property interest)
3. Send automatic text
4. Send email alert to agent
5. Add to CRM (HubSpot or Twenty)

**SETUP TIME:** 15 minutes

**HOW TO SET IT UP:**
```
1. Get the form's webhook URL from your website builder
   → Typeform: Settings → Connect → Webhook → Copy URL
   → OR Google Forms: Extensions → Form Publisher → Webhook

2. Open n8n → New Workflow

3. Add node: "Webhook"
   → URL: https://[your-n8n-domain.com]/webhook/new-lead
   → Copy this URL, paste into your form builder's webhook field

4. Add node: "Google Sheets"
   → Connect your Google account
   → Spreadsheet ID: [create a Google Sheet, copy ID from its URL]
   → Sheet name: "Leads"
   → Operation: Append
   
5. Add node: "Twilio" (for SMS)
   → Account SID: [from twilio.com/console]
   → Auth Token: [from twilio.com/console]
   → From: [your Twilio phone number]
   → To: {{$json.body.phone}}
   → Message: "Hi {{$json.body.name}}, thanks for reaching out! I'll send details shortly."

6. Add node: "Email" (for agent alert)
   → Use Gmail or SMTP
   → To: [agent@youragency.com]
   → Subject: "🚨 New Lead — {{$json.body.name}}"
   → Body: "Property: {{$json.body.property}} \n Phone: {{$json.body.phone}}"

7. Connect the nodes: Webhook → Google Sheets → Twilio (in a row)
   Also connect: Webhook → Email (parallel path)

8. Click "Save" → Click "Activate" (toggle at top)
```

---

## Automation 2 — Property Listing Cross-Poster

**WHAT IT DOES:** Post a new listing to Zillow, Realtor, Facebook Marketplace, and Craigslist with one click.

**TRIGGER:** Agent fills out ONE Google Form with property details + uploads photos

**STEPS:**
1. Agent submits Google Form (address, price, beds, baths, sqft, description, photos)
2. n8n formats for each platform
3. Posts to Zillow via API
4. Posts to Realtor.com via API
5. Posts to Facebook Marketplace
6. Posts to Craigslist
7. Sends confirmation text

**SETUP TIME:** 15 minutes

**HOW TO SET IT UP:**
```
1. Create a Google Form with these fields:
   → Address (short answer)
   → Price (short answer)
   → Bedrooms (short answer)
   → Bathrooms (short answer)
   → Square feet (short answer)
   → Description (paragraph)
   → Photos (file upload)

2. Open n8n → New Workflow → Name it "Property Cross-Poster"

3. Add node: "Google Sheets Trigger"
   → Connect Google account
   → Spreadsheet: [link to the Sheet your form feeds into]
   → Every: 1 minute

4. Add node: "HTTP Request" (for Zillow)
   → Method: POST
   → URL: https://api.zillow.com/webservice/SubmitListing.htm
   → Auth: Add your Zillow API key

5. Add node: "HTTP Request" (for Facebook Marketplace)
   → Method: POST
   → URL: https://graph.facebook.com/v22.0/[page-id]/marketplace_listings
   → Auth: Facebook Page Access Token

6. Add node: "HTTP Request" (for Craigslist)
   → Method: POST
   → URL: https://api.craigslist.org/...

7. Add node: "Twilio" (confirmation)
   → To: [agent phone]
   → Message: "✅ {{address}} is live on Zillow, Realtor, Facebook, Craigslist"

8. Save → Activate
```

---

## Automation 3 — Appointment Reminder (No-Show Reducer)

**WHAT IT DOES:** Texts the buyer/seller 24 hours before a showing, then 1 hour before. If they don't confirm, alerts the agent to call.

**TRIGGER:** Calendar event created in Google Calendar

**STEPS:**
1. New showing in Google Calendar
2. n8n picks it up
3. Texts: "Confirm your showing tomorrow at 2pm? Reply YES"
4. If YES → reminder 1 hour before
5. If NO → cancel, alert agent
6. If no reply in 4 hours → alert agent to call

**SETUP TIME:** 10 minutes

**HOW TO SET IT UP:**
```
1. Open n8n → New Workflow → "Showing Reminder"

2. Add node: "Google Calendar Trigger"
   → Calendar: [select your calendar]
   → Trigger on: Event created
   → Filter: "showing" in title

3. Add node: "Twilio"
   → To: [client phone]
   → Message: "Hi, your showing at {{event.location}} is tomorrow at {{event.time}}. Reply YES to confirm."

4. Add node: "Wait" → 4 hours

5. Add node: "IF"
   → YES → Wait until 1 hour before → Send reminder text
   → NO or no reply → Email agent to call client

6. Save → Activate
```

---

# CONTRACTORS (Roofing, Painting, Home Services)

## Automation 1 — Estimate Request → Quote Generator

**WHAT IT DOES:** Someone asks for a quote on your website → they get a professional estimate via email in 2 minutes.

**TRIGGER:** Quote form submitted on website

**STEPS:**
1. Form comes in (name, address, service type, square feet)
2. n8n calculates price from your pricing sheet
3. Generates PDF quote with your logo
4. Emails quote to customer
5. Adds lead to CRM
6. Texts you: "New estimate sent to [Name] for $[Amount]"

**SETUP TIME:** 15 minutes

**HOW TO SET IT UP:**
```
1. Create Google Sheet called "Pricing Sheet":
   Column A: Service Type (Roof Repair, Roof Replace, Painting)
   Column B: Price Per Square Foot
   Column C: Minimum Charge

2. Open n8n → New Workflow → "Estimate Generator"

3. Add node: "Webhook"
   → URL from your website form
   → Gets: name, email, phone, address, service, sqft

4. Add node: "Google Sheets"
   → Read pricing sheet
   → Match service type → get price per sqft

5. Add node: "Code"
   → JavaScript: total = sqft × pricePerSqft
   → If total < minimum → use minimum

6. Add node: "Gmail"
   → To: [customer email]
   → Subject: "Your Free Estimate from [Company Name]"
   → Body: the estimate with price breakdown

7. Add node: "Twilio"
   → To: [your phone]
   → Message: "💰 New estimate sent to {{name}} for ${{total}}"

8. Save → Activate
```

---

## Automation 2 — Job Schedule & Crew Reminder

**WHAT IT DOES:** Texts your crew the night before with job address, start time, and what to bring.

**TRIGGER:** Job confirmed in calendar

**STEPS:**
1. Job confirmed
2. n8n checks weather for tomorrow
3. If clear → texts each crew member at 7pm
4. If rain → texts "Canceled" + reschedules

**SETUP TIME:** 10 minutes

**HOW TO SET IT UP:**
```
1. Open n8n → New Workflow → "Crew Reminder"

2. Add node: "Cron" → Runs every day at 7:00 PM

3. Add node: "Google Calendar"
   → Get events for tomorrow
   → Filter for "job" or "crew" in title

4. Add node: "OpenWeatherMap" (check weather)
   → Get forecast for job address

5. Add node: "IF"
   → Clear weather → continue
   → Rain → send cancel texts

6. Add node: "Twilio" (to each crew member)
   → Message: "🚧 Job tomorrow: [address]. Start: [time]. Bring: [equipment]."

7. Save → Activate
```

---

## Automation 3 — Review Request After Job Done

**WHAT IT DOES:** 3 days after a job is done, texts the customer asking for a Google review with direct link.

**TRIGGER:** Job marked "Completed"

**STEPS:**
1. Job marked complete
2. Waits 3 days
3. Texts: "Mind leaving a review? [Google Review Link]"
4. If 5 stars → auto-post to Facebook
5. If less than 5 → alert you to call them

**SETUP TIME:** 10 minutes

**HOW TO SET IT UP:**
```
1. Create Google Sheet "Completed Jobs" with: name, phone, service, date

2. Open n8n → "Review Request"

3. Add node: "Google Sheets Trigger" → watch for new rows

4. Add node: "Wait" → 3 days

5. Add node: "Twilio"
   → Message: "Hope you love your [service]! Mind leaving a quick review? [Google Review Link]"

6. Add node: "Wait" → 7 days

7. Add node: "IF"
   → No review → send one more nudge
   → 5-star → HTTP Request → Facebook Graph API (auto-post)
   → Less → Email you: "⚠️ [Name] left [stars] stars — call them"

8. Save → Activate
```

---

# BOOKKEEPING / ACCOUNTING

## Automation 1 — Expense Auto-Categorizer

**WHAT IT DOES:** Every receipt that arrives by email gets read by AI, and the amount + category gets logged into your expense sheet automatically.

**TRIGGER:** Email with "Receipt" or "Invoice" in subject

**STEPS:**
1. Gmail watches for receipts
2. AI reads it (merchant, amount, date, category)
3. Logs to Google Sheets or QuickBooks
4. Weekly summary email

**SETUP TIME:** 15 minutes

**HOW TO SET IT UP:**
```
1. Open n8n → "Expense Auto-Categorizer"

2. Add node: "Gmail Trigger"
   → Search: "subject:receipt OR subject:invoice"
   → Check every: 5 minutes

3. Add node: "OpenAI" or "Gemini"
   → Prompt: "Extract merchant, total amount, date, category. Return JSON."

4. Add node: "Google Sheets"
   → Append: merchant, amount, date, category, receipt link

5. Optional: Add node: "QuickBooks" or "Xero" (if client uses them)

6. Save → Activate
```

---

## Automation 2 — Invoice → Payment Reminder Chain

**WHAT IT DOES:** Sends invoice, then auto-reminds at 3, 7, and 14 days late. Stops when paid.

**TRIGGER:** New invoice created

**STEPS:**
1. Invoice created in Google Sheets or QuickBooks
2. Day 3: "Friendly reminder — invoice #[number] due"
3. Day 7: "Overdue — please pay within 3 days"
4. Day 14: "Final notice — late fee applies"
5. Day 21: Alert bookkeeper to call
6. When paid → stop, send thank-you

**SETUP TIME:** 10 minutes

**HOW TO SET IT UP:**
```
1. Create Google Sheet "Invoices" with: invoice#, client, email, amount, due_date, status

2. Open n8n → "Payment Reminder Chain"

3. Add node: "Cron" → Runs daily at 9:00 AM

4. Add node: "Google Sheets"
   → Read all rows where status ≠ "Paid"

5. Add node: "Code"
   → days_overdue = today - due_date

6. Add node: "Switch" (by days overdue)
   → 1-2: Skip
   → 3-6: Gmail → "Friendly reminder"
   → 7-13: Gmail → "Overdue"
   → 14-20: Gmail → "Final notice"
   → 21+: Gmail → alert bookkeeper

7. To detect payment:
   → Add "Gmail Trigger" watching for "Payment Received"
   → When found → Update sheet: status = "Paid"
   → Send thank-you

8. Save → Activate
```

---

## Automation 3 — Monthly Financial Report

**WHAT IT DOES:** On the 1st of every month, emails a PDF report of income, expenses, profit, and tax estimate.

**TRIGGER:** First day of the month

**STEPS:**
1. Pull last month's transactions
2. Calculate totals
3. Generate PDF
4. Email to client + accountant

**SETUP TIME:** 10 minutes

**HOW TO SET IT UP:**
```
1. Open n8n → "Monthly Report"

2. Add node: "Cron" → 0 9 1 * * (9am on 1st of month)

3. Add node: "Google Sheets"
   → Read "Expenses" where date = last month
   → Read "Income" where date = last month

4. Add node: "Code"
   → total_income = SUM, total_expenses = SUM
   → profit = income - expenses
   → tax_estimate = profit × 0.30

5. Add node: "Gmail"
   → To: [client email], CC: [accountant]
   → Subject: "📊 Your Monthly Financial Report — [Month]"
   → Body: summary numbers
   → Attach: report as PDF (use "HTML" node to generate it)

6. Save → Activate
```

---

# MEDICAL OFFICES

## Automation 1 — Appointment Booking → Confirmation

**WHAT IT DOES:** Patient books online → gets confirmation text + intake forms + calendar event for doctor.

**TRIGGER:** Booking form submitted or staff enters it

**STEPS:**
1. Booking comes in (name, phone, email, date, time, doctor, reason)
2. Sends confirmation text
3. Emails intake forms
4. Adds to Google Calendar
5. Texts staff: "New patient booked"
6. 24h before: reminder text

**SETUP TIME:** 15 minutes

**HOW TO SET IT UP:**
```
1. Open n8n → "Appointment Booking"

2. Add node: "Webhook"
   → URL from your booking system

3. Add node: "Twilio" (confirmation)
   → Message: "✅ Confirmed: Dr. [doctor] on [date] at [time]"

4. Add node: "Gmail" (intake forms)
   → Attach: intake-form.pdf, medical-history.pdf

5. Add node: "Google Calendar"
   → Create event: "[Patient Name] — [Reason]"

6. Add node: "Twilio" (staff alert)
   → Message: "📅 New booking: [name] — [reason]"

7. Save → Activate
```

---

## Automation 2 — Prescription Refill Request

**WHAT IT DOES:** Patient requests refill → checks last fill date → routes to doctor if eligible.

**TRIGGER:** Patient emails "refill" or submits form

**STEPS:**
1. Request comes in (patient name, medication, pharmacy)
2. Check last prescription date
3. If >30 days ago → email doctor to approve
4. If <30 days → auto-reply: "Need an appointment for a new prescription"

**SETUP TIME:** 10 minutes

**HOW TO SET IT UP:**
```
1. Create Google Sheet "Patient Prescriptions": name, medication, last_filled, pharmacy

2. Open n8n → "Refill Request"

3. Add node: "Gmail Trigger" → search "refill"

4. Add node: "Gemini" → extract: name, medication, pharmacy

5. Add node: "Google Sheets" → look up last_filled date

6. Add node: "Code" → days_since = today - last_filled

7. Add node: "IF"
   → >=30 days → Gmail to doctor with approve button
   → <30 days → Auto-reply: "Please schedule an appointment"

8. Save → Activate
```

---

## Automation 3 — No-Show → Re-Booking Sequence

**WHAT IT DOES:** Patient doesn't show → texts them to reschedule → if no reply in 2 hours → alerts front desk.

**TRIGGER:** Staff marks "No Show"

**STEPS:**
1. Appointment marked No Show
2. Texts patient: "Want to reschedule?"
3. If they book → done
4. If no reply in 2 hours → alert front desk to call
5. If still nothing in 24 hours → charge late fee

**SETUP TIME:** 10 minutes

**HOW TO SET IT UP:**
```
1. Open n8n → "No Show Recovery"

2. Add node: "Google Calendar Trigger"
   → Event updated with "No Show"

3. Add node: "Twilio"
   → Message: "We missed you! Reschedule here: [link]"

4. Add node: "Wait" → 2 hours

5. Check if new appointment appeared

6. Add node: "IF"
   → Booked → "See you on [new date]!"
   → Not booked → Alert front desk: "Please call [phone]"

7. Save → Activate
```

---

# WEBSITE DESIGN

## Automation 1 — New Lead → Proposal Generator

**WHAT IT DOES:** Someone fills out "I need a website" → gets a proposal with 3 package options and a booking link.

**TRIGGER:** Contact form submission

**STEPS:**
1. Form comes in (name, email, business type, pages, deadline)
2. Match to package (Basic/Business/Ecom)
3. Email proposal with packages
4. Add to CRM
5. Text you: "New lead — [Name]"

**SETUP TIME:** 10 minutes

**HOW TO SET IT UP:**
```
1. Create Google Sheet "Website Packages": Package | Price | Pages | Features

2. Open n8n → "Website Proposal"

3. Add node: "Webhook" → from your website form

4. Add node: "Code"
   → ≤3 pages → Basic
   → 4-8 pages → Business
   → Has ecom → Ecommerce

5. Add node: "Gmail"
   → To: [lead email]
   → Subject: "Your Website Proposal"
   → Body: package options + booking link

6. Add node: "Twilio" → alert you

7. Save → Activate
```

---

## Automation 2 — Client Project Tracker

**WHAT IT DOES:** When you mark a milestone done in Google Sheets, it texts the client and you automatically.

**TRIGGER:** You update a row in Google Sheets

**STEPS:**
1. You mark "Done" in the sheet
2. Text client: "Your [milestone] is ready!"
3. Text you: "Client notified, waiting for feedback"
4. Weekly summary: progress so far

**SETUP TIME:** 10 minutes

**HOW TO SET IT UP:**
```
1. Create Sheet "Project Tracker": Client | Milestones | Statuses

2. Open n8n → "Project Tracker"

3. Add node: "Google Sheets Trigger" → watch for changes

4. Add node: "Code" → find what just changed to "Done"

5. Add node: "Twilio" (text client)
   → "✅ [Milestone] is complete! Reply APPROVED or CHANGES"

6. Add node: "Twilio" (text you)
   → "📋 [Client] — sent for review"

7. Save → Activate
```

---

## Automation 3 — Hosting Renewal & Uptime Monitor

**WHAT IT DOES:** Checks every hour if client sites are online. If down, restarts server and texts you. Sends renewal invoices 30 days before due.

**TRIGGER:** Cron (every hour), or billing date approaching

**STEPS:**
1. Every hour: ping each client site
2. If down → wait 5 min → try again
3. Still down → restart server + text you
4. 30 days before renewal → email invoice
5. 7 days overdue → pause site + text

**SETUP TIME:** 10 minutes

**HOW TO SET IT UP:**
```
1. Create Sheet "Clients": Name | URL | Hosting Cost | Renewal Date

2. Open n8n → "Uptime Monitor"

3. Add node: "Cron" → every hour

4. Add node: "HTTP Request" → GET [client URL]

5. Add node: "IF"
   → 200 OK → do nothing
   → Error → Wait 5 min → try again
   
   → Still down → SSH (restart nginx or docker) + Twilio alert

6. For billing: Cron daily at 9am
   → Check renewal dates
   → 30 days away → Email invoice
   → 7 overdue → Warning text
   → 14 overdue → Suspend + text

7. Save → Activate
```

---

# MARKETING TEAMS

## Automation 1 — Content Calendar → Social Posts

**WHAT IT DOES:** Plan posts in a Google Sheet. n8n publishes them to LinkedIn, X, Instagram, TikTok on the right day.

**TRIGGER:** You add a row to the sheet with date + content

**STEPS:**
1. You fill in: Date, Platform, Content, Image Link
2. n8n checks every morning
3. Publishes via SocialClaw or Buffer
4. Marks as "Published" in sheet
5. Weekly report email

**SETUP TIME:** 15 minutes

**HOW TO SET IT UP:**
```
1. Create Sheet "Content Calendar": Date | Platform | Content | Image | Hashtags | Status

2. Open n8n → "Content Publisher"

3. Add node: "Cron" → Every day at 8am

4. Add node: "Google Sheets"
   → Read rows where date = today AND status is blank

5. For each row:
   → "SocialClaw" or "HTTP Request" → Post to platform
   → "Google Sheets" → Update status = "Published"

6. Sunday cron: Count weekly posts → email report

7. Save → Activate
```

---

## Automation 2 — Lead Capture → Email Sequence

**WHAT IT DOES:** Someone downloads a freebie → gets 5 emails over 2 weeks → books a call.

**TRIGGER:** Lead magnet form submitted

**STEPS:**
1. Form submitted
2. Instant: "Here's your freebie"
3. Day 2: Related tip
4. Day 5: Case study
5. Day 9: "What are you struggling with?"
6. Day 14: "Book a call"
7. If they reply anytime → alert sales team

**SETUP TIME:** 10 minutes

**HOW TO SET IT UP:**
```
1. Open n8n → "Lead Nurture"

2. Add node: "Webhook" → from your landing page

3. Add node: "Google Sheets" → save lead

4. Add node: "Gmail" — INSTANT
   → "Here's your [freebie]!"

5. Add node: "Wait" → 2 days → Gmail: tip

6. Add node: "Wait" → 3 days → Gmail: case study

7. Add node: "Wait" → 4 days → Gmail: "What's your challenge?"

8. Add node: "Wait" → 5 days → Gmail: "Book a call"

9. After each email: Check for reply
   → If reply → STOP → alert sales team

10. Save → Activate
```

---

## Automation 3 — Competitor Monitoring

**WHAT IT DOES:** Watches 3 competitors' blogs/RSS. Alerts you when they make a move.

**TRIGGER:** Competitor publishes new content

**STEPS:**
1. Watch RSS feeds
2. AI summarizes each new post
3. If "new client" or "hiring" → high alert email
4. Sunday: weekly digest

**SETUP TIME:** 15 minutes

**HOW TO SET IT UP:**
```
1. Create Sheet "Competitors": Name | RSS Feed URL | Notes

2. Open n8n → "Competitor Watch"

3. Add node: "RSS Feed Trigger"
   → URL: [competitor's RSS feed]
   → Every 6 hours

4. Add node: "Gemini"
   → Summarize article, classify: new client? new feature? hiring?

5. Add node: "IF"
   → High threat → "🚨 COMPETITOR ALERT" email
   → Low → add to weekly digest

6. Save → Activate
```
