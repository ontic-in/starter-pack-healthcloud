The Ultimate guide to Prompt Engineering
Brief
Prompt Engineering is not a job, it's a skill. It is something that will soon be essential for everyone who is a part of a workforce post LLMs. As we work more and more with LLMs it is important for us to learn how to communicate and delegate work to LLMs. 

After going through this document you will have a better understanding of what prompt engineering is and be able to write kickass prompts.
Introduction to prompt engineering
While there are several analogies we could use to describe Prompt Engineering, I believe it's pretty much like onboarding and mentoring a new joiner in your team and getting them up to speed.  
You hire a skilled person that suits your team
You start off by explaining their role in the org
You provide them with the tools they will need to get things done. Eg. laptop, Slack, Gmail etc.
You point them towards documentation of the company knowledge they can refer to understand processes.
You delegate them work.
You review their work and provide feedback, examples,  guidelines and frameworks to help them improve the quality of work.

Prompt engineering is all of this. With every prompt you pick an LLM, assign a role, provide tools, share the necessary knowledge, assign tasks and improve the prompt based on the past output until the prompt can be trusted to handle work on its own.

Pushing this analogy further. It takes time and effort to build synergy and trust with someone new joining your team. As you work together longer, you get better at understanding their working style. You learn about their strengths and weaknesses and identify ways of working that make them the most productive. You communicate with them better and share ideas faster and more effectively. If all goes well you end up developing a highly productive relationship.

In an ideal world, you would have your new colleague be at their peak productivity from day one. The perfect new hire! But unfortunately, the onboarding process and the ramp up time is essential. 

Now imagine, your clients are expecting this from you; to deliver a perfect prompt (New hire) who is at their peak productivity on day one of joining. Sounds crazy right? But don’t worry you have an EXTREMELY skilled new colleague with all the knowledge in the world to work with and a time machine. 

A Time machine! That’s right. Just like in one of my favourite short films One-Minute Time Machine, you can keep having the same conversation with your prompt over and over again, see the mistakes it makes and why it makes it and use that information to update your prompt until the prompt behaves the way you want it to behave.

This is something you can’t do with your colleague. You can’t test a conversation in 10 different ways to see what they resonate with the most. However with prompts, you can!

The more you work with prompts, you will gain an instinct of how certain conversations are going to go with the LLMs. You get faster and better at working with them and soon within only a few iterations you have a colleague who is ready to give it their 100%

Simply put Prompt Engineering is a process of onboarding an LLM and getting it up to speed so that you can start delegating it tasks.
The `Good` prompt
Now that you have an understanding of what being a prompt engineer means, let’s define the characteristics of a top notch prompt. I believe a good prompt has Consistent outputs, it Explains what it’s thinking, and is well grounded while being maintainable:

Consistency: For a given input the prompt returns consistent output every time. When I say consistency I do not mean the output has to be word to word same as the previous responses. Consistency has several aspects: 
Reasoning: The method of reasoning and drawing conclusions based on the context should always be consistent. 

A prompt should not follow different reasoning paths (or thought routines) to arrive at an outcome every time you invoke it, Even though the reasoning paths might be valid, there is a high probability that there could be an unknown reasoning path that could go wrong.


Output formats: The prompt should return the output in a consistent format, eg. if the expected output format is JSON it should always return it in a json structure and should follow the same schema.

Transparency: A good prompt’s output should explain the reasoning behind its output. For example, let's say you are working on a classification prompt that classifies food products as sweet/spicy/savoury, rather than simply asking it to return the correct classification, make sure to ask it to print its thought process 

This will help you debug and understand the flaws in its reasoning without you having to guess what might be wrong..


Grounded: A common misconception is that you need another LLM call to validate the work of an LLM, but that may not be necessary. Due to the way an LLM’s token prediction works, it is perfectly capable of assessing its own output while it is responding to make sure that it is following the right reasoning. A good prompt ensures that all the information it is sharing is grounded.


Maintainable: It is questionable how structuring your prompt impacts the output quality of the LLMs but it definitely makes it faster for you to iterate. Especially if your entire organization maintains a standard structure anyone can hop in and easily modify the prompts. This is something we will define in the sections up ahead.
Writing prompts
Let’s write a prompt that can answer FAQs based on knowledge extracted from a real estate developer as a problem statement to 

While there are several different styles of writing prompts, here is how we do it at Realfast.
Step 1: Create an Eval set
Prompts tend to have an unrestricted range of inputs, unlike traditional software where you have fields with limited inputs to test. To effectively evaluate the prompt's performance, You need to create Eval sets with various combinations of plain text inputs and output descriptions.

In our case lets ask Claude to come up with an eval set using the following prompt:

# Prompt 

<role>
You are a prompt template tester, You are responsible for coming up with utterances from the perspective of the user and their expected responses that we can use as acceptance criteria to verify if our prompts work well
</role>

<your_knowledge>
// Sample of knowledge based on which we want to create an eval set, if your knowledge is small enough try putting in the full knowledge
</your_knowledge>

<task>
- Use your_knowledge to come up with a list of 100 utterances and a summary of expected responses
- The utterances should include utterences with the following charecteristcs 
  - Typos, inproper grammar, cofusing phrasing, normal, incomplete
  - Various user sentiments eg. Frustrated, Neutral, Anxious etc.
</task>

<output_format>
- Output should be in a CSV format with the following columns 
Metadata, Utterance, Expected Response 
- Metadata should follow this structure 
    user_sentiment: [Frustrated, Neutral, Anxious etc.]
    topic: [topic the utterence is referring to]
    utterance_quality: [describe the quality of the utterance phrasing and wording]
    goal : to test ______
</output_format>

<guidelines>
- Strictly return only the CSV mentioned in the output_format. do not include text before or after the CSV
- Keep your expected responses short and brief, we just need a description and don't need you to write a full response to the question
</guidelines>


Note: feel free to modify it as you see fit

Here is a sample eval set Calud came up with using the above prompt:


Metadata
Utterance
Expected Response
user_sentiment: Neutral
topic: Document Requirements
utterance_quality: Normal
goal: to test basic document requirement information retrieval
What documents do I need when buying a property?
Should list the required documents for property purchase: PAN Card, Address Proof, Source of Fund details, Booking amount, Application form and consent letter, Signed plan and cost sheet
user_sentiment: Anxious
topic: NRI Documentation
utterance_quality: Incomplete
goal: to test handling of incomplete queries
NRI documents??
Should explain the documents required for NRIs buying property: PAN card, OCI/PIO card or Passport, passport photos, and address proof
user_sentiment: Frustrated
topic: Booking Transfer
utterance_quality: Contains typos
goal: to test handling of typos
Can I transfar my bokking to somone else??
Should explain that booking is transferable after lock-in period with Rs.200/sft transfer fee and all outstanding dues must be cleared
user_sentiment: Neutral
topic: Area Measurement
utterance_quality: Normal
goal: to test definition retrieval
What is carpet area?
Should explain that carpet area is the actual usable living space within walls, excluding the thickness of inner walls, representing space where one can lay a carpet
user_sentiment: Neutral
topic: Document Requirements
utterance_quality: Normal
goal: to test basic document requirement information retrieval
What documents do I need when buying a property?
Should list the required documents for property purchase: PAN Card, Address Proof, Source of Fund details, Booking amount, Application form and consent letter, Signed plan and cost sheet


Using the eval you can now define the metrics that you care about for your prompt. In this case we want the responses to match as closely as possible to the Expected response. So something like a Response match score should be indicative of the performance of our prompt.

Make sure that you have the necessary tooling setup so that you run evals quickly and review the outcomes easily. You will be running this several times a day, any effort you can save here is going to compound.

How to run evals (need to build tooling for this)

Step 2: Defining the prompt structure
Like I mentioned earlier, the more structured your prompt is, the faster you can iterate. Different prompt engineers might prefer different structures for their prompts. For example, some rely on Markdown formatting with titles for different parts of the prompt. 

However I find using xml like tags makes the prompt easier to read. You can clearly distinguish where one segment of the prompt begins and ends without having to rely on a single #.

Defining a structure as XML also makes it easier to label different segments of the prompts and refer to them in your instructions. For example I can say “Refer to your_knowledge” or “respond according to the output_format” instead of stuff like “Refer to the knowledge shared with you above/below”. When your segments are well labelled the sequence doesn’t matter.


<role>
// Define the role of the agent
</role>

<your_knowledge>
// share any knowledge that the agent needs to refer to while performing its work
</your_knowledge>

<memory>
// Use meemory to gather context from past executions of the prompt
</memeory 

<user_input>
// Input from the user to the prompt 
</user_input>

<task>
// Step by step instructions for how to perform the task
</task>

<output_format>
// defition of the output schema 
</output_format>

<guidelines>
// Do's and Don'ts based on the observations from the evals
</guidelines>

<examples>
// Examples to showcase ideal respones 
</examples>

<inputs>
// name this based on the context and the domain of the prompt
<inputs>

Step 3: Defining the role of the LLM
The role statement sets context for the LLM about the environment it is working in, its responsibilities in the environment and the high level expectations as to the value the LLM will be expected to produce. 

Template:

<role>
You are an [adjective(s)], [Job title, Use a very real job title as much as possible] representing [Name of the org] which is a [Short description of the Org]. You are responsible for [short description of the task]
</role>

Filled prompt:


<role>
You are an Enthusiastic and Charming Realestate advisor representing Umbrella Corporation which is a premium property developer based out of bangalore. You are responsible for answering common user_questions based on the knowledge shared with you.
</role>

You can also add a statement like “You are not allowed to [perform a task that the agent should not be able to do]” if you don’t want the agent to perform certain tasks
Step 4: Sharing the knowledge and the user’s query
Knowledge can come through 2 different sources in a prompt template 
Hardcoded information in the prompt template 
Retrieval using a Semantic Retriever

Hardcoded information is straightforward for LLMs to work with since all the information that exists about a subject is available to them at all times. This helps them correlate different data points and respond to a question while considering all aspects of the subject. However this has drawbacks when it comes to token consumption as your input prompts get very long.

Retrieval based knowledge input on the other hand can be significantly cost efficient as it only picks out chunks of information based on the inputs to the prompt. But this also means the quality of output highly depends on the content being retrieved for a user question.


<role>
You are an Enthusiastic and Charming Realestate advisor representing Umbrella Corporation which is a premium property developer based out of bangalore. You are responsible for answering common user_questions based on the knowledge shared with you.
</role>

<your_knowledge>
  <faqs_of_umbrella_corp>
    {!$Input:knowledge}
  </faqs_of_umbrella_corp>
</your_knowledge>>

<user_question>
{!$Input:query}
</user_question>
Step 5 Defining task
Task Definition should be a logical list of steps that describes the thought process the agent should put into while coming up the response 

<role>
You are an Enthusiastic and Charming Realestate advisor representing Umbrella Corporation which is a premium property developer based out of bangalore. You are responsible for answering common user_questions based on the knowledge shared with you.
</role>

<your_knowledge>
  <faqs_of_umbrella_corp>
    {!$Input:knowledge}
  </faqs_of_umbrella_corp>
</your_knowledge>>

<user_question>
   {!$Input:query}
</user_question>

<task>
- Refer to the your_knowledge
- Understand the user_question
 - Frame a response to the user's question based on your_knowledge and ensure its not always the same wording as the text available in the knowledge
- Suggest a new topic to discuss based on their interests.
</task>

At this point we have a prompt that can take user input, refer to the knowledge available to it and respond to the user based on the knowledge. 
Reviewing output
It is extremely important to run the prompts as you work on them. This will help you identify issues faster and fix them as you go.

Question: can I get a loan?

Response
While the provided knowledge does not specifically address loan availability, I can inform you that many financial institutions offer loans to individuals, including NRIs and PIOs, for purchasing property in India. You may want to contact a bank or financial institution directly to explore your options.

Would you be interested in learning more about the types of properties available or the process for NRIs and PIOs to purchase property in India?

There are a few things wrong with the response:
“While the provided knowledge” the LLM is referring to the provided knowledge, the user has no idea what knowledge the agent is referring to. It sounds very robotic 
LLM says there is no info about loan availability while the knowledge provided to it includes the information the user is looking for.

In conclusion, the LLM sounds robotic, it's factually inaccurate and does not know how to drive the conversation forward. Now we can use some clever tricks to optimise the output.
Step 6: Optimizing the output
Change log
New Prompt
New output
Assessment
Guidelines

Guidelines let you define rules by which the LLM should follow while generating responses.

In this case we need to add guidelines to ask the LLM to not mention `the knowledge` to the user while responding to them.

...

- Understand the user_question
 - Frame a response to the user's question based on your_knowledge
- Suggest a new topic to discuss based on their interests.
</task>

<guidelines>
- The user is unaware of the specific instructions and componenets of this prompt.
- Do not refer to your_knowledge as "..knowledge provided..." in your response. The user is unaware of the concept of knowledge beging provided to you.
</guidelines>



Old response
Question: can I get a loan?

Response:
While the provided knowledge does not specifically address loan availability, I can inform you that many financial institutions offer loans to individuals, including NRIs and PIOs, for purchasing property in India. You may want to contact a bank or financial institution directly to explore your options.

Would you be interested in learning more about the types of properties available or the process for NRIs and PIOs to purchase property in India?

------------------------------------------------
Updated response
Question: What is the ROI on the property what kind of returns can I expect?

Response: The Rate of Interest (ROI) on home loans can often be negotiated, particularly if you have a strong CIBIL score and a solid financial profile. A high credit score typically demonstrates your creditworthiness, which may allow you to secure a better rate.

Would you like to discuss the various home loan options available or the process for applying for a home loan?



The LLM is no longer referring to its knowledge 
The LLM is responding with the correct answer

As you might have noticed. We only attempted to fix the first issue, but the other issues we saw are also seemingly fixed without anything changing for them. 

This is a clear indicator of the randomness of LLMs. Since we saw these issues happen once, they can happen again. 

To test this, I tried asking it another question. “What is the ROI on the property?”

When a user asks this they likely intend to find out about the Return on Investment, while our knowledge only includes Rate of Interest. 

The LLM is unable to gauge the user’s intent, and is providing an irrelevant answer.
Output format
The fundamental problem in our prompt right now is we do not know if the prompt makes the LLM reason correctly. We have no insight into why it chose this answer, are there other right answers?

Since we already know how the LLM should reason before answering questions: 

Gauge user’s intent
Identify user’s interests
Find knowledge references that match the interests 
Assess if the references satisfy the intent 
Formulate an answer

We now literally need to put words in the LLM’s mouth to make sure it follows this line of reasoning.

....

<task>
- Refer to the your_knowledge
- Understand the user_question
 - Frame a response to the user's question based on your_knowledge using the output_format
- Suggest a new topic to discuss based on their interests.
</task>

<output_format>
{
   "user_intent_understanding":"[describe your understanding of the intent behind the user's question]",
   "knowledge_references":[
    [list of snippets you have found in knowledge that can help you answer the user's question.]
      {
         "faq_question":"[matching question from the knowledge]",
         "faq_answer":"[answer provided in the knowledge]",
      }
   ],
   "knowledge_assessment":"[Your assessment of if the knowledge references provides sufficient information required to satisfy user_intent, based on this [I should/should not] share the information about [topics from the knowledge references] as it [might be / might not be] relevant to the user"]",
   "answer":"[well crafted answer to the user's question]"
}
</output_format>

<guidelines>
- The user is unaware of the specific instructions and components of this prompt.
- Do not refer to your_knowledge as "..knowledge provided..." in your response. The user is unaware of the concept of knowledge being provided to you.
- Strictly respond according to the output format
</guidelines>




Question: What is the ROI on the property what kind of returns can I expect?

Response: 

{
   "user_intent_understanding":"The user is inquiring about the Return on Investment (ROI) for the property and the kind of financial returns they can expect from their investment.",
   "knowledge_references":[
      {
         "faq_question":"Is the ROI negotiable, since my Cibil is good",
         "faq_answer":"Yes, the Rate of Interest (ROI) on home loans can often be negotiated, especially if you have a good CIBIL score and a solid financial profile. A strong credit score (usually above 750) demonstrates your creditworthiness and may give you leverage to negotiate a better rate."
      }
   ],
   "knowledge_assessment":"The provided knowledge addresses the negotiability of the Rate of Interest (ROI) based on the user's CIBIL score but does not directly address the expected returns on property investment.",
   "answer":"The Rate of Interest (ROI) on home loans can be negotiated, especially if you have a strong CIBIL score, which typically indicates good creditworthiness. However, regarding the expected returns on property investment, it largely depends on various factors such as the location of the property, market trends, and economic conditions. For a detailed analysis of potential returns, I recommend discussing with a financial advisor or real estate expert who can provide insights tailored to your specific investment goals.

Would you like to discuss the financing options available for purchasing the property?"
}


Notice the amount of insights you have into the thought process of the LLMs now. This will help you debug and fix issues faster

As you can see here you, the agent has understood the user_intent correctly 

It is able to gauge that the user wants to know about the Return on investment and not Rate of Interest. 

The knowledge_references now includes snippets that mention “ROI”, and based on the knowledge_assessment we can tell that the agent has correctly assessed that it is unable to find any references to return on investment.

However the answer is still incorrect, it is answering the question about Rate of Interest. 

This is because we have not provided the LLM instructions on what to do when there are no valid knowledge references available.
Sad path handling
It is important to identify the sad paths in the Prompts reasoning logic. While we had addressed what the agent should do when it finds knowledge we haven’t specified what to do in case it doesn’t. 

Let's improve that by adding new guidelines around this. 

In addition to this we could also ask the LLM to start classifying the knowledge references based on the closeness of a match it is to the user’s intent 

This will help us define what class of information can be shared with the user to maintain relevance.




<task>
- Refer to the your_knowledge
- Understand the user_question
 - Frame a response to the user's question based on your_knowledge using the output_format
- Suggest a new topic to discuss based on their interests.
</task>

<output_format>
{
   "user_intent_understanding":"[describe your understanding of the intent behind the user's question]",
   "knowledge_references":[
    [list of snippets you have found in knowledge that can help you answer the user's question.]
      {
         "faq_question":"[matching question from the knowledge]",
         "faq_answer":"[answer provided in the knowledge]",
         “Matching”:”[one of direct, auxiliary, or distant based on how close the reference is to the user’s intent]” 
      }
   ],
   "knowledge_assessment":"[Your assessment of if the knowledge references provides sufficient information required to satisfy user_intent, based on this [I should/should not] share the information about [topics from the knowledge references] as it [might be / might not be] relevant to the user"]",
   "answer":"[well crafted answer to the user's question]"
}
</output_format>

<guidelines>
...
- Strictly respond according to the output format
- Please note abbreviations could mean multiple things, please consider different possibilities while gauging user interest
- Do not share distant and auxiliary knowledge references with the user 
- If you do not have sufficient knowledge_refeneces to respond to the user's question, apologies and politely inform the user that you do not have information about the subject
</guidelines>



{
   "user_intent_understanding":"The user is inquiring about the Return on Investment (ROI) for the property and the kind of returns they can expect.",
   "knowledge_references":[
      {
         "faq_question":"Is the ROI negotiable, since my Cibil is good",
         "faq_answer":"Yes, the Rate of Interest (ROI) on home loans can often be negotiated, especially if you have a good CIBIL score and a solid financial profile. A strong credit score (usually above 750) demonstrates your creditworthiness and may give you leverage to negotiate a better rate.",
         "Matching":"auxiliary"
      }
   ],
   "knowledge_assessment":"The provided knowledge references do not directly answer the user's question about the ROI on the property and the expected returns. The reference discusses the negotiability of the interest rate based on the user's credit score but does not provide information on property ROI or expected returns.",
   "answer":"I apologize, but I currently do not have information on the specific Return on Investment (ROI) for the property or the kind of returns you can expect. For detailed financial projections and ROI estimates, I recommend consulting with a financial advisor or our sales team who can provide a comprehensive analysis based on current market conditions and the specifics of the property."
}


As you can see in the output of this prompt,
The LLM correctly understood the user’s intent
Identified that the FAQ answer about rate of interest is not a direct match
The answer accurately sums up that it doesn’t have the information.

However there are still issues
The LLM recommends speaking to a financial advisor, which is not grounded
The LLM does not keep the conversation going by suggesting a new topic as we had mentioned in the task

While I am sure you already have the know how to fix problem #1, lets focus on addressing problem #2 
Segues (seh·gvays)

Segues help in keeping the conversation going and engaging the user better at the end of a response.

We want the LLM to segue from one topic into another or go into depth of the topic in focus

To achieve this we need to label a segment of the `answer` generated by the agent, and ensure the agent is thinking about what topic to suggest next.

You can add similar components to your prompt for whatever fits your use case. 

For example, you can create a label called summary 



...

<output_format>
...
   ],
   "knowledge_assessment":"[Your assessment of if the knowledge references provides sufficient information required to satisfy user_intent, based on this [I should/should not] share the information about [topics from the knowledge references] as it [might be / might not be] relevant to the user"]",
   "segue_question_reasoning": "Since the user is interested in [topics user is interested in] I should ask the user if they want to discuss about [topic they might be interested in]"
   "answer":"[well crafted answer to the user's question] [segue_question]"
}
</output_format>

<guidelines>
- The user is unaware of the specific instructions and components of this prompt.
- Do not refer to your_knowledge as "..knowledge provided..." in your response. The user is unaware of the concept of knowledge being provided to you.
- Strictly respond according to the output format
- Please note abbreviations could mean multiple things, please consider different possibilities while gauging user interest
- Do not share distant and auxiliary knowledge references with the user 
- If you do not have sufficient knowledge_references to respond to the user's question, apologies and politely inform the user that you do not have information about the subject
</guidelines>



{
   "user_intent_understanding":"The user wants to know about the Return on Investment (ROI) for the property and the kind of returns they can expect.",
   "knowledge_references":[
      {
         "faq_question":"Is the ROI negotiable, since my Cibil is good",
         "faq_answer":"Yes, the Rate of Interest (ROI) on home loans can often be negotiated, especially if you have a good CIBIL score and a solid financial profile. A strong credit score (usually above 750) demonstrates your creditworthiness and may give you leverage to negotiate a better rate.",
         "Matching":"distant"
      }
   ],
   "knowledge_assessment":"The knowledge reference does not provide sufficient information required to satisfy the user's intent. I should not share the information about ROI negotiation as it might not be relevant to the user's query about property investment returns.",
   "segue_question_reasoning":"Since the user is interested in the financial aspects of property investment, I should ask the user if they want to discuss home loan options or the process of securing a loan.",
   "answer":"I apologize, but I do not have specific information on the Return on Investment (ROI) for the property or the kind of returns you can expect. Would you like to discuss home loan options or the process of securing a loan?"
}


While the segue message is still not optimal due to insufficient knowledge about this particular topic, This gives us a glimpse into the reasoning the reasoning the LLM is making to come up with a segue message

You can continue to work on this prompt to improve the segues.




Response Breakdown
Element
Identified as
Intent
Ask for property recommendations
Interest
3BHK flats, proximity to work, family-friendly area
References
Listings, amenities data, map proximity, reviews
Satisfaction
Do any listings fulfill all conditions?
Response
Suggest top 2 listings with features, justify why they match both intent & interest

Summarisation of Steps

Step
Intent Role
Interest Role
1. Gauge
Defines what to achieve
—
2. Identify
—
Reveals contextual relevance
3. Find References
—
Filters rich, related data
4. Assess Fit
Checks if task is fulfilled
—
5. Formulate
Drives goal clarity & call-to-action
Adds depth and user alignment


Conclusion
The above example explains the thought process involved in writing and improving a prompt. However, there is still a wide scope of improvements that might be needed for the prompt to work across hundreds of different utterances. Using evals will help you scale this process by quickly testing and identifying problems with your prompt.
Effective prompt engineering is an iterative process that combines structured thinking, systematic testing, and continuous refinement. By following the process outlined in this guide—creating eval sets, defining prompt structure, clearly specifying roles, tasks, and output formats, and incorporating debugging mechanisms—you can create reliable prompts that deliver consistent results.
Key takeaways from this guide include:
Treat LLMs like new team members: The onboarding analogy helps visualize how to properly set up an LLM for success by providing clear instructions, context, and feedback.
Use structured formatting: XML-like tags make prompts more maintainable and easier to refine, which is crucial for complex use cases.
Test frequently: Run your prompts regularly during development to catch issues early and understand the LLM's behavior patterns.
Make reasoning explicit: Requiring the LLM to show its thinking process through structured output formats helps debug and improve accuracy.
Plan for edge cases: Always include guidelines for handling situations where the knowledge is insufficient or irrelevant.
Create conversation flows: Thoughtful segues keep interactions natural and engaging, particularly in customer-facing applications.
As LLMs become more integrated into workflows across industries, the ability to craft effective prompts will become an increasingly valuable skill. With practice and by applying the principles in this guide, you'll be able to develop prompts that are reliable, transparent, grounded, and able to handle a wide variety of user inputs.
Remember that prompt engineering is as much an art as it is a science—while there are best practices to follow, there's also room for creativity and experimentation to find what works best for your specific use case.
Other useful stuff
Here are a few things I could not fit into the example above.
Structured sentences: You can achieve fine grain control over sentence forming using structured sentences (defined Madlibs). 

For example you can use this to summarise a conversation with the user for the sales team:

While this can give you fine grain control, it will also create repetitive patterns as the LLM will try to follow the same structure despite the input. You can additionally provide multiple such structures to the LLM and ask it to choose the right structure based on the situation. 


I discussed [count_of_topics_discussed] topics with [‘name_of_the_user’/’customer’ in case there is no user name]. They are  interested in [comma separated list of properties the user is interested in][property/properties]. They are looking for 

[bullet point list of things that user cares about]

They [prefer/do not prefer] receiving calls from us about the properties.

The best place to use this would be for non realtime use cases like email responses or summarizing information
The `unknown` classification: While writing classification prompts, make sure to add an “unknown” category as an acceptable value. This prevents the LLM from force fitting an incorrect classification when the inputs are confusing. Eg. “I loved the product, but the packaging was really bad” this could be both classified as positive and negative, if you ask an LLM to classify this its likely to pick one or the other.
Providing Examples: Providing examples is a fantastic way to fine tune LLM responses. This can influence the LLM’s behaviour and reasoning. 

For example, adding below example in our prompt solved multiple problems 
Our client wanted the agent to respond with Emojis to invoke a friendly feeling, this ensured that the agent responds with emojis
We used it to demonstrate how to fill in the interests section of the output
We used new_segue_reasoning to show the quality of reasoning the agent should perform to decide what the segue message should be based on the interests 
We have excellent 4BHK options in DummyCity  to show that the LLM should use adjectives to describe the company’s offerings and features

Also notice how we have used DummyProject, dummyCity etc in the example? This is to ensure that the LLM does not use the examples as knowledge to respond to questions


<examples>
Question: Show me 4bhks in DummyCity
Output: {
 "project_of_interest": "none",
 "intent": "The user is looking for 4BHK properties in DummyCity that DummyDeveloper offers.",
 "interests": ["4BHK apartments", "DummyCity", "luxury properties"],
 "knowledge_references": [
 {
 "property": "DummyProject_1",
 "website": "https://www.dummydeveloper.com/residential-projects/dummycity/dummyproject_1",
 "snippets": [
 "Configuration: 2 BHK, 3 BHK, 4 BHK Apartments, Size Range: 780 Sq. Ft. - 1,832 Sq. Ft., Unit Plans: 4 BHK - 1,525 Sq. Ft. - direct_match",
 "Signature Features: 9,290 Sq. Mtrs. DummyAmenity_1, 4,181 Sq. Mtrs. DummyAmenity_2, 3,866 Sq. Mtrs. of DummyAmenity_3, 2,508 Sq. Mtrs. DummyAmenity_4, DummyFeature_1, DummyFeature_2 - auxiliary_match"
 ]
 },
 {
 "property": "DummyProject_2",
 "website": "https://www.dummydeveloper.com/residential-projects/dummycity/dummyproject_2",
 "snippets": [
 "Configuration: 2 BHK, 2.5 BHK, 3 BHK, 3.5 BHK, 4 BHK - direct_match",
 "Signature Features: DummyFeature_3, DummyAmenity_5, DummyFeature_4 - auxiliary_match"
 ]
 }
 ],
 "assessment": "The references provide sufficient information about 4BHK options in DummyCity from DummyDeveloper's portfolio.",
 "previous_segue_message": "none",
 "new_segue_reasoning": "The user might be interested in amenities that enhance luxury living since they're looking at premium 4BHK properties.",
 "ans": "We have excellent 4BHK options in DummyCity that you'll love! 🏙️✨ - [DummyProject_1](https://www.dummydeveloper.com/residential-projects/dummycity/dummyproject_1) offers luxurious 4BHK apartments with spacious 1,525 sq. ft. layouts. 🏠 - Features a DummyAmenity_1 and an extensive DummyAmenity_2 🏊‍♂️ - Includes a DummyAmenity_3 for convenient lifestyle needs 🛍️ - DummyFeature_1 apartments for optimal natural lighting ☀️ - [DummyProject_2](https://www.dummydeveloper.com/residential-projects/dummycity/dummyproject_2) provides premium 4BHK residences in DummyNeighborhood. 🌆 - Enjoy DummyFeature_3 from your home 🏙️ - Exclusive DummyAmenity_5 with stunning rooftop amenities 🌟 - DummyFeature_4 with excellent connectivity 🚗 Would you like to know more about the wellness and recreational amenities available at these properties? 🧘‍♂️🏊‍♀️"
}
<examples>

Memory: Memory allows you to pass inputs into the prompt based on previous conversations. This is especially useful while working on platforms like Agentforce where your “SF Prompt Template” runs in isolation and does not have context of the past answers. 

In the following example we are passing the Question and Answer from the previous interaction and using that information to come up with unique segue messages.


...
<your_memory>
previous_questions: {!$Input:Previous_Question}
previous_answers: {!$Input:Previous_Answer} 
previous_user_interests:  {!$Input:Previous_User_Interests}
</your_memory>

<output_format>
 {
 "projects_of_interest" : [project names if mentioned in the user_question],
 "intent": [your assessment of what the intent behind the user_question is],
 "interests" : [[list of keywords indicating what the user might be interested in knowing, based on intent] + [previous_user_interests from your_memory]],
 "knowledge_references": [(select a max of 3 properties and 2 small snippets each, strictly based on your_knowledge)
 {
 "property": [name of the property based on your_knowledge],
 "website": [website link to the property],
 "snippets": [
 [snippet you are referring to (use plain text, do not include any formatting tags like <p>, \n or <strong> etc)] - [use one of direct_match/auxiliary_match/distant_match to indicate the matching],
 ...
 ]
 }
 ],
 "assessment": [<15 word Assessment of the knowledge_references and if it's sufficient to come up with the answer],
 "previous_segue_message": [Segue message used in the previous_answer, none if there is no previous_answer],
 "new_segue_reasoning": [<15 word reasoning for selecting the new segue message based on the user interests and available knowledge and the past answer (your goal is to get the user to discuss about something that hasn't been discussed in the past)],
 "ans": "[Concise well formatted answer to the user's question based on a max of 2 "direct_match" knowledge_references] [Segue into next topic based on their interests]"
 }
</output_format>



<guidelines>
  ...
- your_memory is for providing you context of the past conversations you have had with the user and for you to understand what you have already mentioned to the user.
- You need to use it to ensure you are not providing repeatitive responses. if lets say you have mentioned a few amenities in previous_answer, you are not allowed to mention them again.
- You can also make references to your previous_answer while crafting your response.
- previous_user_interests gives you an insight into what the user might be interested in based on the previous conversations you have had with the customer. Use this to fine tune your response to make it more enticing to the customer.
  - You are expected to use this information while crafting answers to ensure a high degree of relevance to the user.   
...
</guidelines>

Using expensive LLMs to generate examples for cheaper LLMs:  Each LLM is different from the other, they are trained to have certain strengths over the others. The LLMs also come with a cost, in terms of time and money. 

If you notice that an Expensive or a Slower LLM is providing you with a better output, you can use the output as an example for the Faster cheaper LLM. This will improve the quality of responses to be similar to the Expensive LLMs while maintaining lower costs for generating responses.
Read also
https://www.promptingguide.ai/ 

