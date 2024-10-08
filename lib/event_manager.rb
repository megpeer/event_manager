require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'time'



def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def clean_phone_number(phone_number)
 phone_number.tr!('^0-9', '')
 phone_number.delete_prefix("1")

 if phone_number.length == 10
  return phone_number
 else
  phone_number = "N/A"
 end
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

# def save_thank_you_letter(id,form_letter)
#   Dir.mkdir('output') unless Dir.exist?('output')

#   filename = "output/thanks_#{id}.html"

#   File.open(filename, 'w') do |file|
#     file.puts form_letter
#   end
# end

def hours(reg_date)
  time = Time.strptime(reg_date, '%m/%d/%Y %k:%M')
  reg_date = time.hour.to_int
  @timehash[reg_date] += 1
end

def days(reg_day)
  time = Time.strptime(reg_day, '%m/%d/%Y %k:%M')
  reg_day = time.wday.to_i
  @dayhash[reg_day] += 1
end

puts 'EventManager initialized.'

@timehash = {}
ary = (0..23).to_a
ary.each{|a| @timehash[a] = 0}

@dayhash = {}
days = (0..6).to_a
days.each{|a| @dayhash[a] = 0}
@namedayhash = {}

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

# template_letter = File.read('form_letter.erb')
# erb_template = ERB.new template_letter

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  phone_number = clean_phone_number(row[:homephone])
  reg_date = hours(row[:regdate])
  reg_day = days(row[:regdate])
  legislators = legislators_by_zipcode(zipcode)




#   form_letter = erb_template.result(binding)

#   save_thank_you_letter(id,form_letter)

puts "#{name} #{zipcode} #{phone_number}"
end



  @namedayhash[:sunday] = @dayhash[0]
  @namedayhash[:monday] = @dayhash[1]
  @namedayhash[:tuesday] = @dayhash[2]
  @namedayhash[:wednesday] = @dayhash[3]
  @namedayhash[:thursday] = @dayhash[4]
  @namedayhash[:friday] = @dayhash[5]
  @namedayhash[:saturday] = @dayhash[6]

sorted_timehash = @timehash.sort_by {|_key, value| value}.to_h
puts ""
puts "sorted hours of reg date"
puts sorted_timehash


puts ""
puts "sorted days of the week reg date"
sorted_dayshash = @namedayhash.sort_by {|_key, value| value}.to_h
puts sorted_dayshash
