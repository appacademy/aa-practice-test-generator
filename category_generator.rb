require 'csv'
require 'colorize'
require 'fileutils'

# Instructions
system("clear")
puts "Welcome to a/A's Practice Assessment Generator".cyan
puts "This generator will create a practice test based on your input. " \
      "You can choose how many problems from each category to include in your test. "
puts "This program will generate 3 files in this folder: practice_test, spec, and solution. " \
      "Complete the practice_test file, running the spec file to check your answers. " \
      "When your time is up (you are timing yourself, right?), compare your answers to the solutions."
puts "NB: Ben's quick addition to the generator now ensures that you don't get random questions" \
    "you've already completed, so you can generate random tests of a reasonable size while ensuring" \
    "you don't just keep doing the same problems over and over again and miss some problems you've never" \
    "encountered before. If you would like to reset the list to the full list of questions at any point," \
    "just type 'reset'."
puts "Good luck!"

# read in csv with test info
tests = CSV.read('resources/mutated_list.csv', headers: true, header_converters: :symbol, converters: :all)
# add a method to reset the mutated list to the original list if desired

# list possible categories
categories = Array.new
tests.each do |test|
  categories << test[1]
end
categories = categories.uniq
puts "Possible categories: #{categories.join(", ")}".magenta
puts

# get user request
puts "Input your requests, separated by commas and spaces please"
puts "Example input: " + "array: 2, recursion: 1, sort: 1".yellow
puts "If you would like ALL problems from ALL categories, input: " + "all".yellow
puts "If you'd like all problems, EXCEPT bonus problems, input: " + "all, except: bonus".yellow
puts "If you'd like to reset the generator to all original problems again, input: " + "reset".green

input = gets.chomp.split(", ")

system("clear")
puts "I am generating a practice assessment that will be saved"
puts "as 'practice_assessment/' in your current directory"

# === BEN'S RESET EDIT ===
if input == ["reset"]

  original_csv = CSV.table('resources/list.csv', headers: true, header_converters: :symbol, converters: :all)
  #rewrite the mutated_list with the original list csv file with all the questions again
  File.open('resources/mutated_list.csv', 'w') { |f| f.write(original_csv.to_csv) }

  puts "Generator successfully reset to all original questions.".green
  sleep(1)
  puts "Input your requests, separated by commas and spaces please"
  puts "Example input: " + "array: 2, recursion: 1, sort: 1".yellow
  puts "If you would like ALL problems from ALL categories, input: " + "all".yellow
  puts "If you'd like all problems, EXCEPT bonus problems, input: " + "all, except: bonus".yellow
  input = gets.chomp.split(", ")
end

if input == ["all"]
  input = categories.map { |cat| cat += ": 20" }
end

if input == ["all", "except: bonus"]
  no_bonus_categories = categories.reject {|cat| cat == "bonus"}
  input = no_bonus_categories.map { |cat| cat += ": 20" }
end

categoryrequests = Hash.new(0)
input.each do |request|
  req = request.downcase.split(": ")
  categoryrequests[req[0]] = req[1].to_i
end

# make test array for each category
master = Array.new
categories.each do |category|
  problems_in_category = Array.new
  tests.each do |test|
    if category == test[1]
      problems_in_category << test
    end
  end

  # pick tests at random from each category
  n = categoryrequests[category]
  master = master.concat(problems_in_category.sample(n))
end

# create new test, spec and solution files
FileUtils.rm_r("category_assessment") if File.directory?("category_assessment")
Dir.mkdir("category_assessment")
practice_test = File.open("category_assessment/practice_test.rb", "w")
spec = File.open("category_assessment/spec.rb", "w")
solution = File.open("category_assessment/solution.rb", "w")

# require rspec and the practice_test in the spec
spec << "require 'rspec'" << "\n"
spec << "require_relative 'practice_test'" << "\n"

# loop through master tests and add text to the new files
master.each do |test|
  practice_test << File.read(test[2]) << "\n"
  spec << File.read(test[3]) << "\n"
  solution << File.read(test[4]) << "\n"
end

# === BEN'S MUTATIVE LIST EDIT ===
# loop through master tests and remove those tests from the CSV file
new_csv = CSV.table('resources/mutated_list.csv', headers: true, header_converters: :symbol, converters: :all)
new_csv.delete_if { |row| master.include?(row) }
#rewrite the mutated_list with the csv file minus all the rows that were already generated as test questions
File.open('resources/mutated_list.csv', 'w') { |f| f.write(new_csv.to_csv) }

# close the files that were just created
practice_test.close
spec.close
solution.close

sleep(0.5)
puts 
puts "Done!"
