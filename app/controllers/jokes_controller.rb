class JokesController < ApplicationController
  def new
    @joke = Joke.new
  end

  def create
    @joke = Joke.new(joke_params)
    @joke.user = current_user # Link the joke to the logged-in user

    # 1. Define the Business Asset: The System Prompt
    system_prompt = "You are a highly cynical, stand-up comedian AI. You do not explain your jokes. You are blunt, witty, and slightly dark. The user will provide you with a few random keywords. Create a punchy, one-liner or short two-sentence joke incorporating the exact keywords provided by the user. Return ONLY the joke itself in plain text. Do not include any introductory phrases like 'Here is a joke' or 'Sure!'."

    # 2. Call the AI (Using Le Wagon's RubyLLM setup)
    # We pass the user's keywords as the prompt, and inject our system_prompt
    ai_response = RubyLLM.chat(
      prompt: "Here are my keywords: #{@joke.keywords}",
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

  private

  def joke_params
    # We only allow the user to submit keywords. The AI generates the content!
    params.require(:joke).permit(:keywords)
  end
end
