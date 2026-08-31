# Outline

### Problem setup - the prime directive (Simon)

<!-- Sara Altman: main idea: the prime directive is in trouble! -->

- Your VP is vibe-coding an analysis in Cursor right now
  <!-- Simon Couch: "it was a cold may day, i went out on a jog, cold swim in lake michigan"
  - increasingly absurd / fantastical
  - i don't actually remember hearing this for the first time at all -->
  - Becoming normal to spin up a coding agent, ask a question, and go with whatever the answer is
- Like any good technical keynote, need to start off with a Star Trek reference
  <!-- Simon Couch: "Baader–Meinhof phenomenon" -->
  - Prime directive (I don’t actually know what the Star Trek meaning is)
    <!-- Simon Couch: Realizing that we are once again in alien metaphor territory😭 -->
  - The prime directive’s impact at Posit
- The prime directive is losing/in danger
  - Cite Joe: "In the battle between convenience and correctness, convenience is winning"

### Problem nuance I - the prime directive has always faced threats (Simon)

<!-- Simon Couch: maybe Simon, too

setup might be 3-4 min -->

<!-- Sara Altman: main idea: earlier point was an overstatement

it has always been threatened -->

<!-- Sara Altman: I stray note I had somewhere else:

the second part of the introduction -- the mission to explore -- fits in well too

"The prime directive of the space explorers, notice, was not their mission but rather an important safeguard to apply in pursuing that mission. Their mission was to explore, to "boldly go where no one has gone before", and
all that. That's really our mission too: to explore how software can add new abilities for data analysis. And our own prime directive, likewise, is an important caution and guiding principle as we create the software to support our mission.
Here, then, are two motivating principles: the mission, which is bold exploration; and the prime directive, trustworthy software. We will examine in the rest of the book how to select and program software for data analysis, with these principles as guides. A few aspects of R will prove to be especially relevant; let's examine those next." -->

<!-- Simon Couch: Or is this the tension between the mission and the PD? Probably not–keep for later
“Posit shouldn’t be doing this bc of the Prime Directive” -->

- This framing might be an overstatement; battle might be an overstatement
- We didn’t live in a perfect world where everyone followed the prime directive before LLMs (There were prior adversaries to the prime directive)
  - Spreadsheeting? Or some story that speaks to the other ways this went wrong before, esp. if it’s my own experience
  - Tareef actually spoke about the PD at posit::conf in 2019
  - And we worked to make tools for that world, balancing the prime directive with the motivations and incentives of the real world
  - Our LLM-related tools work much the same
- The VPs vibe analyzing, claude hallucinating are new threats, but the presence of threats is not new

### Problem nuance II - and so why go on at all? The mission (Sara)

- Transitional sentence:
  - Point to the unsaid thing. All this talk about how difficult it is, why approach AI at all? This is a choice that we made. And it’s a choice everyone (or most) are making
    <!-- Sara Altman: I've heard this, people come up to me and talk to me about this -->
    <!-- Sara Altman: exploration has led me to where I am

    finding new paths to understand the data -->
    <!-- Sara Altman: helping others to learn
    laid the groundwork that I am a teacher. if the materials aren't working it's not the students work, it's the materials' -->
    <!-- Sara Altman: got into data science because I learned R and suddenly had the tools to explore. satisfying feeling -->
  - The PD does not live on its own. It governs a mission
  - The tension between the two is purposeful
- There’s a second part of Chambers’s intro (and star trek): the mission
  - “Exploration is our mission; we and those who use our software want to find new paths to understand the data and the underlying processes.”
  - Then put story about learning R/data science
- Posit explores
  - Quick hit example. You see that in x, y, z. (sql). Give people something to recognize and will make people smile and excited.
- Also our users explore
  - Instead of fighting those VPs vibe-analyzing (or x person, y person), we need to work with them
    - If Simon hasn’t done it before, callback or do it now where we have empathy for them
    - Lens of seeing people vibe coding as a positive because they are more interested than they have been before
  - There’s nothing wrong with VPs wanting to answer questions with data – they are part of the mission
  - Think about the actual environment people work in, and the entire agent-user system

### An initial resolution (Sara)

- Here’s a common thought about AI
  - It’s untrustworthy, but useful.
    - Possibly as an example of untrustworthiness: bluffbench/bluffbench2
    - Example of usefulness: but they wrote the code to make the plots
    <!-- Sara Altman: if not doing untrustworthy example, don't do usefulness example -->
  - To make it trustworthy, humans need to verify the output from or supervise agents
    - This is even pretty much what we said about Databot a year ago
    - Show flotation device post. This was one of the first things I did on the AI team
  - “Human in the loop”
    <!-- Sara Altman: "slap a human on it" -->
- There’s a few problems with this approach
  <!-- Sara Altman: bring in things not from AI. bring in fun evidence from psychology about why this wouldn't work

  always click accept cookies -->
  -
    <!-- Sara Altman: call back to education in cognitive science

    everything that I learned is that this is the wrong place to put a human, presence of a human does not guarantee correctness -->
    <!-- Sara Altman: or early experience with reproducibility/replicability crisis work.

    the presence of a human does not guarantee correctness -->
  - Humans don’t excel at supervision and verification when it’s the only thing they do.
    - Auto mode example
  - Human decision-making is not a fixed process. Interaction style with the agent, how much they trust the agent, how frequently requests come in, etc. can affect how well this process goes. The presence of a human is not a panacea.
- Transition: so AI is useful but not trustworthy, and humans are useful, but not trustworthy
- So if we are going to move beyond human in a loop, we need a different idea: ecosystem
  - Human affects the agent, agent affects the human
- You are in an ecosystem with an agent, not a loop
  - You were in an ecosystem before with various tools and players, now there’s just something new
  - Figure out how to make that ecosystem function under the prime directive
- Figure out how to make that ecosystem function well
  - To fulfill the mission while still obeying the prime directive
    - *Help the model not be wrong and make it less bad if it is wrong*
      <!-- Sara Altman: the presence of a human is not enough. here's some ways we've designed Posit Assistant that we think are great -->

### Posit Assistant  (Simon)

<!-- Sara Altman: assumes you have the expertise and gives you the right level of detail -->
<!-- Sara Altman: friction -->

- Users are people who know how to code/work with data, want to work in an IDE
- Big ideas: give the model the ability to write code in your session, the ability to show you that code, and an interaction style that keeps the user involved when needed
- Shorten turns / seeing plots helps with correctness
  - “If a 40 page Quarto report is produced, but no one reads it…”
- Seeing the code helps with transparency
- Code in shared environment, and having a *data scientist* be the one in the ecosystem in the first place, helps with reproducibility
- Supposed to speak meaningfully to the idea that it’s an ecosystem

### Call back to problem, lead in to commons (Sara)

<!-- Sara Altman: the big red button -->

- With Posit Assistant, much of the work is in two areas: providing the model with the right tools and building the right interaction style
  - “Have the model write code and show it to the user” or maybe “Have the model write code (the right amount) and show it to the user when necessary)”
- But there’s another lever we can use – have the model write *trusted* code
- Return to the VP vibe analyzing in Cursor
  - Let’s draw this situation out a bit
  - The VP (or the product manager, or the PI, or the physician working with a statistician, etc.)  has a question
  - They have an agent.
  - The agent says it can answer the question!
  - The agent answers the question.
  - The VP shares the answer broadly.
  - The data scientist (or statistician, etc). says, “that doesn’t look right,” runs their own analysis, and produces a different number
- “Looks good button” is even less applicable to commons
- Diagram for Posit Assistant as ecosystem and diagram for commons that is three of the loops
  - Posit Assistant diagram is a subset of the commons loop diagram
- Some kind of setup to commons

### Commons (Simon (and Sara?))

<!-- Sara Altman: empower people. don't give up on convenience -->

- Correctness
  - Use trusted calculations from existing artifacts
  - Harness provides the right content at the right time
  - Feedback loop pushes more queries up the trust ladder over time
- Transparency: The data scientist sees the code that was run
- Reproducibility
- Show examples
- Junction of upholding prime directive and convenience

