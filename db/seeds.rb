puts "Cleaning database..."
Joke.destroy_all
User.destroy_all

puts "Creating dummy user..."
user = User.create!(email: "test@lewagon.com", password: "password")

puts "Creating fake jokes..."
Joke.create!(user: user, keywords: "Developer, Coffee, Bugs", content: "Why do programmers prefer dark mode? Because light attracts bugs.")
Joke.create!(user: user, keywords: "AI, Terminator, Future", content: "I asked my AI for a joke about the future. It just sent me a picture of a battery charger.")
Joke.create!(user: user, keywords: "Ruby, Rails, Fast", content: "How do you know someone is a Ruby developer? Don't worry, they'll tell you.")

puts "Database seeded with #{Joke.count} jokes!"
