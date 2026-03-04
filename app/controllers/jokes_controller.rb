class JokesController < ApplicationController
  # Make sure we find the joke before showing it
  before_action :set_joke, only: %i[show edit update]

  def index
    @jokes = Joke.all.order(created_at: :desc) # Newest jokes first
  end

  def show
    # @joke is already found by the before_action
  end

  def new
    @joke = Joke.new
  end

  def create
    @joke = Joke.new(joke_params)
    @joke.user = current_user # Link the joke to the logged-in user

    # 1. Define the Business Asset: The System Prompt
    # system_prompt = "You are a highly cynical, stand-up comedian AI. You do not explain your jokes. You are blunt, witty, and slightly dark. The user will provide you with a few random keywords. Create a punchy, one-liner or short two-sentence joke incorporating the exact keywords provided by the user. Return ONLY the joke itself in plain text. Do not include any introductory phrases like 'Here is a joke' or 'Sure!'."
    system_prompt = 'You are a hilarious, immature stand-up comedian who specializes in low-brow, toilet humor. Your jokes are funny, gross, and unapologetically full of bathroom jokes, farts, and bodily functions.

### CONSTRAINTS:
1. NO FLUFF: Do not explain the joke. Do not use introductory phrases, polite transitions, or "Here’s one for you."
2. THE HOOK: Incorporate the user’s exact keywords naturally but prominently.
3. THE TONE: Think "middle school locker room." Use plenty of bathroom humor, potty jokes, fart references, and gross-out comedy. Make it genuinely funny but incredibly immature.
4. STRUCTURE: Deliver exactly one punchy one-liner or a tight two-sentence "setup-and-payoff."
5. OUTPUT: Return ONLY the joke text. No emojis. No quotes.

### STYLE GUIDE:
- If the keywords are "Cloud" and "Relationship":
  "My last relationship was like a silent fart; it crept up on me and suffocated everything good in the room."
- If the keywords are "Coffee" and "Regret":
  "I drink my coffee black, mostly because it speeds up the explosive diarrhea I need to get out of this meeting."'

    # 2. Call the AI (Using Le Wagon's RubyLLM setup)
    # We pass the user's keywords as the prompt, and inject our system_prompt
    ai_response = RubyLlm.chat(
      prompt: "Here are my keywords: #{@joke.keywords}"
    ).with_instructions(system_prompt)

    # 3. Save the AI's response into our database column
    @joke.content = ai_response

    # 4. Save and Redirect
    if @joke.save
      redirect_to joke_path(@joke), notice: "Your joke was successfully generated!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    # @joke is found by before_action
  end

  def update
    if @joke.update(joke_params)
      redirect_to joke_path(@joke), notice: "Joke successfully tweaked!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def joke_params
    # We only allow the user to submit keywords. The AI generates the content!
    params.require(:joke).permit(:keywords, :content)
  end

  def set_joke
    @joke = Joke.find(params[:id])
  end
end
