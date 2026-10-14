# Where does the internet actually live? I built a tiny piece of it in 30 minutes

*A non-scary tour of cloud computing, with a real app you can run, break and delete yourself.*

![How one tap travels through AWS](https://raw.githubusercontent.com/sathpal/aws-cloud-101-demo/main/docs/screenshots/architecture-diagram.png)

Ask a room of smart people where Instagram lives and you get a pause. "The cloud." Okay, but where is that? Whose building? What happens, physically, in the half second between tapping Post and your friend seeing the picture?

I run introductory sessions on cloud computing, and I got tired of answering that with diagrams. So I built the smallest honest version of Instagram I could: a guestbook. You open a page on your phone, type your name, where you are joining from and one word, and tap Send. Everyone in the room sees your entry appear. Then we hit it with 200 requests at once and watch what the cloud does about it. Then we delete the whole thing and watch the bill stop.

The code is public and the README takes you from "I have never had an AWS account" to cleanup. This article is the tour.

## Part one: rent a computer you will never see

Everything in the cloud starts with one idea. Somewhere there is a building full of computers, and you can rent one for as long as you like, by the second, without talking to anyone.

On AWS that service is called EC2. One command asks for a small Linux machine and hands it a short script to run when it wakes up. The script installs a web server and writes a page about itself.

![A freshly rented server introducing itself](https://raw.githubusercontent.com/sathpal/aws-cloud-101-demo/main/docs/screenshots/ec2-server-page.png)

Ninety seconds after the command, that page is on the internet. The line that says "data centre" is a real building. The IP address is a real address. Nobody bought that machine, nobody installed anything, and in a few minutes we will throw it away.

That is the whole cloud in one picture. The rest is refinement.

## Part two: describe what you want, let the building build it

Renting one computer by hand is fine. Real systems have dozens of pieces, and nobody wants to click through dozens of screens every time. So the second idea is this: write down what you want in a file, hand the file to the cloud, and let it create everything.

Our guestbook needs four things:

- **Somewhere to keep the web page.** A file store. On AWS that is S3, and the page is literally one file in it.
- **Something to run the code when someone taps Send.** Not a server that sits waiting all day. A function that exists only for the moment it is needed. That is Lambda.
- **Somewhere to keep the entries.** A database that we never have to size or patch. That is DynamoDB.
- **A way to watch it.** Graphs of requests, speed and errors. That is CloudWatch.

All four are described in a single text file about 150 lines long. One command sends it to AWS. Eighty seconds later, everything exists, wired together, with a public address.

![The guestbook, live](https://raw.githubusercontent.com/sathpal/aws-cloud-101-demo/main/docs/screenshots/guestbook-desktop.png)

On-premises, those four things would be a purchase order, a rack, and someone's quarter. Here it is a file.

## Part three: follow one tap

Someone scans the QR code and taps Send. Here is where their tap goes.

![Scan to open the guestbook](https://raw.githubusercontent.com/sathpal/aws-cloud-101-demo/main/docs/screenshots/qr-code-page.png)

1. **Their phone asks S3 for the page.** S3 hands back the HTML file. S3 holds trillions of objects for the world; our page is one of them.
2. **The page sends the entry to the function's address.** Until this moment, our backend code was not running anywhere. It cost nothing. The instant the request arrives, AWS starts a copy of the code, hands it the request, and the code runs for a few milliseconds.
3. **The code writes one row to the database.** The row is copied to three separate data centres automatically before the write is even confirmed.
4. **Every phone in the room polls for updates** and the new entry appears.

You can watch each hop in the AWS console. The file in the bucket. The function's invocation count ticking up. The row in the table, with a timestamp and a six-character tag that says which copy of the code wrote it.

That six-character tag is the setup for the best part.

## Part four: what if everyone hits it at once?

Every real app has a moment it was not built for. A product launch. A results day. A match going to the last ball.

So we simulate one. A script fires 200 requests at the guestbook, 50 at a time. Here is what happened when I ran it:

> 200 requests, 50 at a time, all succeeded, 5.0 seconds total. Handled by 41 distinct copies of the function.

Read that last line again. The code was running in one place. Fifty requests arrived together, so AWS started forty more copies, spread the work across them, and shut them down again afterwards. Average response time: 33 milliseconds. Errors: zero.

Nobody added a server. Nobody got paged at 2 a.m. The dashboard shows a spike and then calm.

![The guestbook on a phone](https://raw.githubusercontent.com/sathpal/aws-cloud-101-demo/main/docs/screenshots/guestbook-phone.png)

This is the property people mean when they say "elastic", and it is the real reason companies moved. Not that the cloud is cheaper per computer. It usually is not. It is that you stop guessing. Guess too low on your own hardware and you crash on launch day. Guess too high and money sleeps in a rack. Here you pay for the forty copies for the five seconds they existed.

## Part five: what it costs, and who is responsible

A room's worth of entries plus a load test plus a dashboard: zero, on a new account. AWS gives new accounts credits that cannot be overspent, and the services we used bill in fractions of a cent per request. The only thing on the bill is the rented computer from part one, which charges by the second while it exists.

Which raises the question of responsibility, and the cloud has a clear answer. AWS is responsible for the building, the hardware and the software underneath you. You are responsible for what you put on it: your keys, your open ports, your data. The classic first-job mistake is not a hacked data centre. It is an access key pasted into a public repository, found by a bot within minutes.

## Part six: the bill stops now

Two commands. One terminates the rented computer. The other empties the file store and deletes everything the file in part two created, then waits for AWS to confirm it is gone.

Try returning a physical server to a vendor after 25 minutes.

## What I want you to take from this

The cloud is somebody else's computer, yes. But it is also three ideas stacked on each other:

1. Computers are rentable by the second.
2. Whole systems can be written down as a file and created on demand.
3. Capacity is not something you guess any more. It follows the traffic.

Everything else, from the 200 services on the AWS console to the job titles, is detail on top of those three.

If you want to feel it rather than read about it, the repo is at [github.com/sathpal/aws-cloud-101-demo](https://github.com/sathpal/aws-cloud-101-demo). The README starts at creating the account and ends with deleting everything. It takes about 90 minutes the first time and costs nothing if you do the last step.

Build it, break it, delete it. Then you will know where the internet lives.
