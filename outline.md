# Problem setup - the prime directive (Simon)

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

# Problem nuance I - the prime directive has always faced threats (Simon)

- This framing might be an overstatement; battle might be an overstatement
- We didn’t live in a perfect world where everyone followed the prime directive before LLMs (There were prior adversaries to the prime directive)
  - Spreadsheeting? Or some story that speaks to the other ways this went wrong before, esp. if it’s my own experience
  - Tareef actually spoke about the PD at posit::conf in 2019
  - And we worked to make tools for that world, balancing the prime directive with the motivations and incentives of the real world
  - Our LLM-related tools work much the same
- The VPs vibe analyzing, claude hallucinating are new threats, but the presence of threats is not new

# Problem nuance II - the mission (Sara)

## The mission

- [needs opening joke]
- And so you might be thinking: why are we doing this at all?!
  - Why wade into AI, if things were already bad and now we've introduced this unpredictable, possibly horrific tool that makes mistakes, and hallucinates, and uses too many em dashes, and is, in some ways, making our lives a little bit worse.  
- There are a few reasons, but first, there's actually a second part of Chamber's discussion of the prime directive (and star trek's).
- Prime directives don't live on its own. The reason it's there is to govern a mission often in tension with the prime directive.
- So what's that mission? 
- Chambers: “Exploration is our mission; we and those who use our software want to find new paths to understand the data and the underlying processes.”
- Note that this isn't _Posit's_ mission, it's not the one you'll find on our website. 
- But I do think it is sort of our collective mission, of me and Simon and most of you all in this room today.
  - "to find new paths to understand the data and the underlying processes."

## Exploration

- For me and many of you all I assume, exploration is not abstract.
- Exploration and curiosity I imagine are what got most of us into this room today. Maybe it was curiosity about a scientific field and you got into data analysis that way, or curiosity about the tools themselves, or about how computers work, or about statistics
- For me it was this. I have always been interested in many things at once. 
- Data is great for this. There's data on everything!
- Without the right tools, though your curiosity is limited. 
- Looking at a dataset felt like looking at the ocean from above. You know things are there, that's there's in incredible amount there, but you can't see it. You have know when to access it. 
- Even with knowledge about statistics and some knowledge of R as an undergrad, I felt like this. 
- But when I learned the R and tidyverse and data science as a grad student, it felt like the ocean revealed itself to me. 
- These tools gave me the ability to see the complexity below the surface and to dig into into data set on any topic -- on x, y, z -- and learn about the world 
- Turn the data over in your hands and say huh that’s interesting and keep digging. Feeling curiosity and wonder just from sitting at my 2016 macbook in a florescently lit classroom typing -- hand typing! if you can imagine -- dplyr and ggplot code 
- The tools enable the curiosity. exploration is the mission -- for the tools users and the tool makers

## So why does Posit make tools for AI? 

- Because that's the mission. Exploration, discovering of new ways to understand data. 
- AI is part of that exploration, not just because we want to explore it, but because our users are too. 
- Want to meet them where they are with tools that make their work more correct and trustworthy, not less.
- And the task is to do that while still fulfilling the prime directive. 


# Posit Assistant lead-in: Adding a person is not enough (Sara)

## A common thought

- Here’s a common thought about AI
  - It’s untrustworthy, but useful.
  <!-- Possible place to add bluffbench/bluffbench2 results. If we do that, also need a counter example of usefulness.-->
  - To make it trustworthy, we need people to to verify the output from or supervise agents.
  - This is a sort of naive "human in the loop" approach. Or what you might call the "slap a human on it" approach.

## Databot 

- And this is close to how we framed the risks of data analysis agents a year ago. 
- Databot flotation device post. This was one of the first things I worked on the AI team. 
- The message was basically: Databot is powerful, but can be wrong. Don't abandon your expertise. 
- Now Databot did a bunch of things and did them well. Our framing, however, put most of the responsibility for correctness on the user, to be aware of the risks, to be skeptical of the output. Underneath it was really one implicit strategy: read the code.
- We didn't really articulate a strategy for helping the user be correct. The strategy was just sort of "make sure you, the human, are there"

## This doesn't work 

- But just having a human there (the "slap a human on it" approach) is not a correctness strategy.
- The specifics of the interaction matter. How you present information to people and the ways in which they engage with it shape their understanding, their trust, and therefore the decisions they make.
- I started my career as an educator. And I've got to tell you, the idea that suddenly people should be reading code to verify that it is correct and that was our strategy for trust raised some red flags. I was skeptical that people were reading code in that way anyways, but also pure reading is not a good strategy for building mental models which is what you need to catch mistakes. It's passive, and I'd spent the past 6 ish years working on putting active learning everywhere I could, but that was really all we offered people in that post.
- Automation bias, approval fatigue. Auto mode example. People accepted 93% of permission requests. 
- The human isn't a fixed component. Humans are not deterministic functions. How they decide depends on trust, social cues, the interaction style, cognitive load, etc. It's mediated by context, and the agent is now part of that context. 
  - Another example: config file 

## Reframe

- The presence of a human does not guarantee correctness.
- The naive “slap a human on it” version of human in the loop assumes the person is a fixed safety component.
- But the person and the agent interact, shaping how each other acts.
- So simply adding a person can't be our strategy for upholding the prime directive.
- The question is not “who checks the output?” but “how do we design the interaction so
the entire system can produce trustworthy work?”
- That gives us two goals:
  - Help the model not be wrong.
  - Make it less bad when it is wrong.

<!-- another stray thought: reproducibility and transparency are really supporting legs of correctness. they both matter for their own reasons as well, but that also support correctness -->

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
