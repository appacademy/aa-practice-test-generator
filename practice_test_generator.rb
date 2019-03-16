require 'csv'
require 'colorize'
require 'fileutils'

# Instructions
system("clear")
puts "I am generating a practice assessment that will be saved"
puts "as 'practice_assessment/' in your current directory"

# Read in csv with test info
tests = CSV.read(
          'resources/list.csv', 
          headers: true, 
          header_converters: :symbol, 
          converters: :all
        )

# Define number of each category test 
categories = {
  recursion: 2,
  array: 1,
  string: 1,
  enumerable: 1,
  sort: 1
}

# Grab appropriate tests for each category
master = []
enumerables = []
omit_problems = ['permutations',
                 'subsets',
                 'eight_queens',
                 'make_better_change',
                 'my_each',
                 'my_all',
                 'my_any',
                 'my_join',
                 'my_reject',
                 'my_select'
                ]

categories.each do |category, num|
  problems_in_category = []
  tests.each do |test|
    if category.to_s == test[1]
      if !omit_problems.include?(test[0])
        problems_in_category << test
      end
      
      if category.to_s == 'enumerable' && omit_problems.include?(test[0])
        enumerables << test
      end
    end
  end

  master.concat(problems_in_category.sample(num))
  if category == :enumerable 
    master.push(enumerables.find { |el| el[0] === 'my_each' })
    enumerables.select{ |el| el[0] === 'my_each' }
    master.concat(enumerables.sample(1))
  end
end

# Create new test, spec and solution files
FileUtils.rm_r("lib") if File.directory?("lib")
Dir.mkdir("lib")
FileUtils.rm_r("spec") if File.directory?("spec")
Dir.mkdir("spec")
practice_test = File.open("lib/practice_test.rb", "w")
spec = File.open("spec/practice_test_spec.rb", "w")
solution = File.open("lib/solution.rb", "w")

# Copy README into preactice directory
FileUtils.cp("./resources/README.md", "./practice_assessment/")

# Require rspec and the practice_test in the spec
spec << "require 'rspec'" << "\n"
spec << "require 'practice_test'" << "\n"

# Loop through master tests and add text to the new files
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

# Close the files that were just created
practice_test.close
spec.close
solution.close

puts "Beep." 
puts "Bop."
puts "Boop." 
puts "Beep." 
puts "Done!"