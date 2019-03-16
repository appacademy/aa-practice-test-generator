require 'csv'
require 'colorize'
require 'fileutils'

# Instructions
system("clear")
puts; puts "Welcome to a/A's Practice Assessment Generator".cyan
puts; puts "This generator will create a practice test based on your input. " \
      "You can choose how many problems from each category to include in your test. "
puts; puts "This program will generate 3 files in this folder: practice_test, spec, and solution. " \
      "Complete the practice_test file, running the spec file to check your answers. " \
      "When your time is up (you are timing yourself, right?), compare your answers to the solutions."
puts; puts "NB: Ben's quick addition to the generator now ensures that you don't get random questions " \
    "you've already completed, so you can generate random tests of a reasonable size while ensuring " \
    "you don't just keep doing the same problems over and over again and miss some problems you've never " \
    "encountered before. If you would like to reset the list to the full list of questions at any point, " \
    "just type 'reset'."
puts; puts "Good luck!"

# read in csv with test info
tests = CSV.read('resources/mutated_list.csv', headers: true, header_converters: :symbol, converters: :all)
# add a method to reset the mutated list to the original list if desired

# list possible categories
categories = Array.new
tests.each do |test|
  categories << test[1]
end
# count how many of each kind of problem remain
category_counter = Hash.new(0)
categories.each { |category| category_counter[category] += 1 }
categories = categories.uniq
puts
puts "Possible categories: #{categories.join(", ")}".magenta
print "Problems remaining per category: |".magenta
category_counter.each { |cat, num| print " #{cat}: #{num} |".magenta }
puts; puts

# get user request
puts "Input your requests, separated by commas and spaces please"
puts "Example input: " + "array: 2, recursion: 1, sort: 1".yellow
puts "If you would like ALL problems from ALL categories, input: " + "all".yellow
puts "If you'd like all problems, EXCEPT bonus problems, input: " + "all, except: bonus".yellow
puts "If you'd like to reset the generator to all original problems again, input: " + "reset".green
puts

input = gets.chomp.split(", ")

# === BEN'S RESET EDIT ===
if input == ["reset"]

  original_csv = CSV.table('resources/list.csv', headers: true, header_converters: :symbol, converters: :all)
  #rewrite the mutated_list with the original list csv file with all the questions again
  File.open('resources/mutated_list.csv', 'w') { |f| f.write(original_csv.to_csv) }

  system('clear')
  puts "Generator successfully reset to all original questions.".green
  sleep(1)
  # read in csv with test info
  tests = CSV.read('resources/mutated_list.csv', headers: true, header_converters: :symbol, converters: :all)
  # add a method to reset the mutated list to the original list if desired

  # list possible categories
  categories = Array.new
  tests.each do |test|
    categories << test[1]
  end
  # count how many of each kind of problem remain
  category_counter = Hash.new(0)
  categories.each { |category| category_counter[category] += 1 }
  categories = categories.uniq
  puts

  puts "Possible categories: #{categories.join(", ")}".magenta
  print "Problems remaining per category: |".magenta
  category_counter.each { |cat, num| print " #{cat}: #{num} |".magenta }
  puts; puts

  puts "Input your requests, separated by commas and spaces please"
  puts "Example input: " + "array: 2, recursion: 1, sort: 1".yellow
  puts "If you would like ALL problems from ALL categories, input: " + "all".yellow
  puts "If you'd like all problems, EXCEPT bonus problems, input: " + "all, except: bonus".yellow
  puts; puts "Input 'quit' or 'exit' if you would like to exit and use 'practice_generator.rb' instead.".green
  puts
  input = gets.chomp.split(", ")
end

if input == ["quit"] || input == ["exit"]
  exit
end

system("clear")
puts "I am generating a practice assessment with solutions that will be saved"
puts "as 'lib/' in your current directory, and specs that will be saved in"
puts "'spec/' in your current directory. To run specs, type 'bundle exec rspec'"

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
  cat = req[0]; num = req[1]
  categoryrequests[cat] = num.to_i
  category_counter[cat] -= num.to_i # decrement category counter too
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
FileUtils.rm_r("lib") if File.directory?("lib")
Dir.mkdir("lib")
FileUtils.rm_r("spec") if File.directory?("spec")
Dir.mkdir("spec")
practice_test = File.open("lib/practice_test.rb", "w")
spec = File.open("spec/practice_test_spec.rb", "w")
solution = File.open("lib/solution.rb", "w")

# Copy README into practice directory
FileUtils.cp("./resources/README.md", "./lib/")

# require rspec and the practice_test in the spec
spec << "require 'rspec'" << "\n"
spec << "require 'practice_test'" << "\n"

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
print "New problems remaining per category: |".magenta
category_counter.each { |cat, num| print " #{cat}: #{num} |".magenta if num >= 0 }
puts; puts
puts "Done!"
