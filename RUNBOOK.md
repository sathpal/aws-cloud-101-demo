# RUNBOOK — Cloud 101 @ SNIT Hyderabad

**Format:** 2-hour session + 30-minute live demo (150 min plan; a 120-min compression is at the end).
**Audience:** engineering students, mostly first exposure to cloud. Optimise for *feel it*, not *cover it*.
**Spine of the session:** one question — *"Where does Instagram actually live?"* — answered by building
a tiny piece of Instagram (a guestbook) in front of them, on their phones, and deleting it at the end.

---

## 0. The night before (30 min)

- [ ] `aws configure` with an IAM access key (see PRESENTER.md). `scripts/preflight.sh` is all green.
- [ ] `STACK=cloud101-backup scripts/deploy.sh` → scan the QR from your phone, post an entry. **This backup stack stays up overnight.**
- [ ] `scripts/blast.sh 200` → open the dashboard link → you should see a spike and 0 errors. `STACK=cloud101-backup scripts/reset.sh`.
- [ ] `scripts/ec2-demo.sh` → page opens → `scripts/ec2-cleanup.sh`. (EC2 is the only thing that bills while idle.)
- [ ] Optional: `scripts/ai-demo.sh`. If it says no model, enable one in Bedrock → *Model access* (Mumbai) or skip the bonus.
- [ ] Optional "wow": enable **Asia Pacific (Hyderabad) ap-south-2** in *Account → AWS Regions* (takes a few minutes), then
      `AWS_REGION=ap-south-2 STACK=cloud101-hyd scripts/preflight.sh` and deploy there — "your data is stored *in this city*."
      Bedrock is not in ap-south-2; keep the AI bonus on Mumbai.
- [ ] Browser tabs pinned, in this order: AWS console home (region = Mumbai) · CloudFormation · S3 · Lambda · DynamoDB ·
      CloudWatch dashboard · EC2 instances · `build/qr.html`. Sign out of everything else. Font size up in the terminal (⌘+ ×3).
- [ ] Phone hotspot ready (college Wi-Fi often blocks odd ports; the demo only needs 80/443, but the *presenter laptop* must reach AWS).
- [ ] Print or keep on phone: the **Fallback matrix** (section 5).

## 1. Timeline (150 min)

| Clock | Block | Goal |
|---|---|---|
| 0:00 – 0:10 | **Hook** | "Where does Instagram live?" Poll the room via the guestbook itself (already deployed? No — use hands). Ask what happens in the 300 ms after you tap a reel. |
| 0:10 – 0:35 | **What is cloud computing** | Definition, the before/after story, the 5 characteristics, IaaS/PaaS/SaaS with the pizza analogy, public/private/hybrid |
| 0:35 – 1:00 | **AWS fundamentals** | 2006 story, global infrastructure (Regions/AZs, Mumbai + Hyderabad), the 8 services you must know, pay-as-you-go, shared responsibility |
| 1:00 – 1:05 | Stretch break | Put the QR on screen *now* so early scanners seed the guestbook |
| 1:05 – 1:35 | **LIVE DEMO (30 min)** | Section 2 below |
| 1:35 – 1:50 | **Uses & benefits, real-world** | Netflix, Hotstar at IPL scale, Zomato/Dream11, NASA, F1, Moderna. Tie every case to something they just saw |
| 1:50 – 2:10 | **Opportunities & pathways** | Roles, salaries reality-check, certifications, free resources, a 30-day plan, AWS Cloud Club at SNIT |
| 2:10 – 2:25 | **Q&A** | Seed questions in section 6 if the room is quiet |
| 2:25 – 2:30 | **Close** | Show the final word cloud, `scripts/destroy.sh` live: "the bill stops now." |

## 2. The 30-minute demo, minute by minute

Before you start: terminal full screen on the left half, browser on the right half. `cd ~/aws-cloud-101-demo`.

### 2.1 (0–4 min) A computer in Mumbai — Amazon EC2
Say: *"Everything cloud starts with renting a computer you never see. Watch."*
```bash
scripts/ec2-demo.sh
```
While it launches (~90 s) narrate: AMI = a ready-made OS image; instance type = size (`t3.micro` = 2 vCPU, 1 GB);
security group = firewall; user-data = "what to do when you wake up"; public IP = address on the internet.
Switch to the EC2 console tab and refresh: show the instance go *pending → running*.
When the page opens: read out the instance ID and the availability zone. *"That's a physical data centre in Mumbai. Nobody bought that machine."*
Optional 20 s: `scripts/ec2-demo.sh 3` → "three more, in three data centres, while I talk."

### 2.2 (4–8 min) Infrastructure as Code — CloudFormation
Say: *"Clicking is fine for one server. Real teams write the infrastructure down as a file."*
Open `infra/guestbook.yaml` in the editor, scroll slowly, name the four resources. Then:
```bash
scripts/deploy.sh
```
Switch to the CloudFormation tab → *Events*: resources appearing one by one. *"This is a database, a website host, a function, and a dashboard being created in 90 seconds. On-prem this is a 3-month purchase order."*

### 2.3 (8–10 min) Put the QR on screen
```bash
scripts/qr.sh
```
Say: *"Scan, type your name, branch and one word that comes to mind when you hear 'cloud'. Go."* Leave the QR up 60 s, then split screen: QR left, guestbook right.

### 2.4 (10–16 min) Follow one request through AWS
Pick a student's entry as it appears. Trace it live:
1. **S3 tab** → bucket → `index.html`: *"the page itself is just a file in storage. S3 stores trillions of objects; your page is one."*
2. **Lambda tab** → function → *Monitor*: *"this code ran only because Priya tapped Send. Before that it consumed nothing, cost nothing."* Open *Code* and show `handler.py` — 80 lines, no server.
3. **DynamoDB tab** → *Explore items*: find Priya's row. *"That row is now stored in three data centres automatically."*
4. Back to the guestbook page: point at the **"servers AWS created for us"** counter and the `served by` badge changing.

### 2.5 (16–21 min) Scale — the moment that lands
Say: *"What if the whole college hits it at once during results day?"*
```bash
scripts/blast.sh 200
```
Open the **CloudWatch dashboard** tab (link printed by deploy). Watch *Requests* spike, *concurrent executions* climb, *errors* flat at zero. Refresh the guestbook: the "servers created" number jumped. *"Nobody added a server. Nobody woke up at 2 am. That's elasticity."* Then `scripts/reset.sh` to remove the bot rows.

### 2.6 (21–25 min) What it costs — and who does what
- **Billing tab** (or Free Tier page): today's charge: ₹0. Explain per-request pricing: Lambda ≈ ₹0.02 per *million* requests after free tier; the whole room for a year would cost less than one samosa.
- **IAM tab**: the `cloud101` user. *"Security is shared: AWS guards the building, you guard the keys."*
- **Global infrastructure**: top-right region switcher → point at Hyderabad. *"There is an AWS region in this city."*

### 2.7 (25–28 min) Bonus — AI is now a cloud API (skip if behind)
```bash
scripts/ai-demo.sh "Explain cloud computing to a first-year student in Hyderabad in 3 lines, with one cricket analogy."
```
*"The same account, the same CLI, a frontier model. This is why cloud skills and AI skills are now the same job."*

### 2.8 (28–30 min) Delete it — "the bill stops now"
Keep the stack up for the closing word cloud; delete at 2:25 in the close instead. Terminate EC2 now though:
```bash
scripts/ec2-cleanup.sh
```
*"Try returning a server to a vendor after 25 minutes."*

## 3. Talking points per topic (the 2-hour content)

### Introduction to Cloud Computing
- **Definition (NIST, in plain words):** computing resources — servers, storage, databases, networking, software — delivered over the internet, on demand, paid for by use.
- **The before story:** a 2005 startup buys servers (₹3–5 lakh each), waits 8 weeks, rents rack space, hires someone to patch them, and guesses capacity. Guess low → site crashes on launch day. Guess high → money sleeps in a rack.
- **The 5 essential characteristics:** on-demand self-service · broad network access · resource pooling · rapid elasticity · measured service. Map each one to something in the demo (self-service = `run-instances`; elasticity = the blast; measured = the ₹0 bill).
- **Service models — pizza analogy:** IaaS = buy ingredients, cook at a rented kitchen (EC2). PaaS = order a pizza base, add toppings (Lambda, RDS). SaaS = order the pizza (Gmail, Canva, ChatGPT). On-prem = grow the wheat.
- **Deployment models:** public (AWS, Azure, GCP), private (a bank's own cloud), hybrid (both; most large Indian enterprises), multi-cloud.
- **Why it matters to *them*:** every app they use runs on it; every job posting for backend, data, ML, DevOps, security asks for it.

### The fundamentals and purpose of AWS
- **Story:** Amazon built internal infrastructure to survive Diwali-scale shopping peaks, then rented it out. S3 launched March 2006, EC2 August 2006. Today the largest cloud provider; the reference against which others are measured.
- **Global infrastructure:** Regions (a city; ≥3 isolated data centre clusters) → Availability Zones → data centres. India: **Mumbai `ap-south-1` (2016)** and **Hyderabad `ap-south-2` (Nov 2022)**. Data residency: an Indian bank can keep data in India.
- **The 8 services to recognise on sight:**
  EC2 (servers) · S3 (object storage) · Lambda (run code without servers) · DynamoDB (NoSQL DB) · RDS (SQL DB) · VPC (your private network) · IAM (who may do what) · CloudWatch (metrics & logs).
  Plus one growing family: Bedrock / SageMaker (AI).
- **Pricing model:** pay-as-you-go, per second/request/GB; no upfront; free tier for learning (AWS moved to a credit-based Free Tier in July 2025 — new accounts get credits for 6 months; check the current page).
- **Shared responsibility model:** AWS is responsible for security *of* the cloud (buildings, hardware, hypervisor). You are responsible for security *in* the cloud (your keys, your open ports, your data). The leaked-access-key story is the classic first-job mistake — mention it.
- **Console vs CLI vs IaC:** three ways to talk to AWS; they just saw all three.

### Key uses and benefits
- Speed (minutes not months) · Elasticity (up *and* down) · Cost (opex, no waste) · Global reach (deploy near users) · Reliability (multi-AZ by design) · Managed services (databases, queues, AI as APIs) · Security & compliance baseline better than most on-prem.
- Common uses: web/mobile backends · storage & backup · big data & analytics · ML/AI · IoT · DR (disaster recovery) · dev/test environments · streaming.

### Real-world applications (publicly documented AWS customers)
- **Netflix** — runs almost entirely on AWS; hundreds of microservices; famously deletes its own servers on purpose (Chaos Monkey) to prove resilience.
- **Hotstar / JioHotstar** — record live-streaming concurrency during ICC Cricket World Cup and IPL (tens of millions of simultaneous viewers) with pre-scaled AWS capacity. *"That's the blast demo, times a few million."*
- **Zomato, Dream11, Ola** — Indian consumer apps that live and die by elasticity (lunch peaks, match-time peaks).
- **NASA JPL** — Mars rover imagery processing and public distribution.
- **Formula 1** — the live race insights graphics on TV come from AWS analytics.
- **Moderna** — designed its COVID-19 vaccine candidate in days using cloud compute.
- **Government / public sector in India** — DigiLocker-style scale, state portals, and many EdTech platforms (BYJU'S, Unacademy have been AWS customers).
  Say "as described in AWS's own case studies" — keep it honest.

### Opportunities and learning pathways for students
- **Roles:** Cloud/DevOps engineer · SRE · Solutions architect · Data engineer · ML engineer · Cloud security · FinOps. Cloud is a *multiplier* on their core branch, not a replacement — an ECE student doing IoT on AWS is rarer and better paid than a generic developer.
- **Certifications, in order:** AWS Certified Cloud Practitioner (CLF-C02, foundation, ~2–4 weeks of prep) → Solutions Architect Associate (SAA-C03, the one recruiters look for) → Developer / SysOps → specialities (Security, ML, Data). Students often get exam vouchers via AWS Educate / AWS Academy / Emerging Talent programmes.
- **Free resources:** AWS Educate (no credit card) · AWS Skill Builder free courses & Cloud Quest game · AWS Academy (ask your department to join) · AWS Free Tier account · AWS Workshops (workshops.aws) · re:Invent talks on YouTube.
- **Community:** AWS User Group Hyderabad, AWS Community Day Hyderabad (annual), start an **AWS Cloud Club** at SNIT (student-run, AWS supports it).
- **30-day plan:** Week 1 — create account, make this guestbook yourself from the repo. Week 2 — Cloud Practitioner course on Skill Builder. Week 3 — put your own project (resume site on S3 + a Lambda API) on GitHub. Week 4 — book the CLF-C02 or present at the college club.
- **Portfolio > certificate:** the repo they just watched is public; challenge them to fork it, add a feature (photo upload to S3, a leaderboard), and send you the link.

## 4. What to show in the console (tab order)
1. Console home, region switcher (Mumbai, Hyderabad)  2. CloudFormation → stack → Events / Resources
3. S3 → bucket → objects, *Properties → Static website hosting*  4. Lambda → function → Code, Monitor
5. DynamoDB → table → Explore items  6. CloudWatch → Dashboards → `cloud101-guestbook-live`
7. EC2 → Instances  8. IAM → Users  9. Billing → Free Tier

## 5. Fallback matrix

| Problem | Do this |
|---|---|
| Laptop can't reach AWS | Phone hotspot. Everything works on mobile data. |
| `deploy.sh` fails live | `STACK=cloud101-backup scripts/qr.sh` — the overnight stack. Say "let me use the one I built yesterday" and move on. |
| S3 website URL 404s | deploy.sh already falls back to the Lambda URL for the QR. Explain "Block Public Access" as a security default — good teaching moment. |
| Students' Wi-Fi blocks the site | Ask them to switch to mobile data; the URL is plain HTTPS/HTTP. |
| CLI credentials broken | Console-only path: CloudFormation → Create stack → upload `infra/guestbook.yaml`; Lambda → upload `build/fn.zip`; S3 → upload `build/index.s3.html`; EC2 → Launch instance → paste `scripts/ec2-userdata.sh` in *User data*. |
| EC2 capacity error for t3.micro | `TYPE=t2.micro scripts/ec2-demo.sh` or `TYPE=t3.small`. |
| Bedrock says no model | Skip 2.7. Do not debug live. |
| Projector dies | Guestbook on their phones *is* the presentation. Keep talking through the page. |

## 6. Seed questions for Q&A
- "Is the cloud just someone else's computer?" (yes — plus automation, scale and a global network you could never build)
- "If AWS Mumbai goes down, does Hotstar go down?" (multi-AZ / multi-region; the shared-responsibility answer)
- "How much does a beginner really pay?" (₹0 with free tier; the horror stories are leaked keys and forgotten EC2)
- "Which is better: AWS, Azure or GCP?" (concepts transfer; learn one deeply, the second takes a week)
- "Will AI replace cloud engineers?" (AI *runs* on cloud; today's demo asked a model through the same CLI)
- "Where do I start tonight?" (the 30-day plan)

## 7. Compressing to 120 minutes
Cut the break, trim "AWS fundamentals" to 15 min (skip pricing detail, show the region map only), drop demo steps 2.6 and 2.7,
and fold real-world cases into the demo narration ("this is Hotstar at 1/1,000,000 scale").

## 8. After the session
```bash
scripts/destroy.sh                      # live, at the close
STACK=cloud101-backup scripts/destroy.sh
scripts/ec2-cleanup.sh
```
Then IAM → delete the `cloud101` access key. Share the repo link with the students.
