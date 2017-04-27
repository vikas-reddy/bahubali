require 'open-uri'
require 'nokogiri'
require 'net/smtp'

INTERVAL = 60

# Websites
BOOKMYSHOW = {
  name: "BookMyShow",
  url: "https://in.bookmyshow.com/buytickets/baahubali-2-the-conclusion-hyderabad/movie-hyd-ET00038693-MT/20170429",
  selector: "ul#venuelist li.list div.details a.__venue-name strong"
}
JUSTICKETS = {
  name: "Justickets",
  url: "https://data.justickets.co/datapax/JUSTICKETS.hyderabad.baahubali-2-the-conclusion.v1.json",
  selector: "div.schedule-listing div.info div.theatre"
}

# Theaters
THEATERS = [
  'BVK',
  'Miraj'
]

# Email configuration
NAME_FROM = 'Vikas Reddy'
EMAIL_FROM = 'sender@gmail.com'
RECIPIENTS = ['recipient1@gmail.com', 'recipient2@gmail.com']
PWD = 'THE_ORIGINAL_PASSWORD'


def formatted_message(content)
<<-MSG
From: Vikas Program <vikas@reddy.com>
To: Vikas Reddy <recipient1@gmail.com>, Swathi <recipient2@gmail.com>
Content-Type: text/html
Subject: Bahubali booking started!

#{content}
MSG
end

def send_email(message)
  smtp = Net::SMTP.new('smtp.gmail.com', 587)
  smtp.enable_starttls
  smtp.start('mail.google.com', EMAIL_FROM, PWD, :login) do
    # puts formatted_message(message)
    smtp.send_message(formatted_message(message), EMAIL_FROM, RECIPIENTS)
  end
end

def check(website)
  url = website[:url]
  doc = Nokogiri::HTML(open(url))

  message = ''
  doc.css(website[:selector]).map(&:text).each do |name|
    THEATERS.each do |theater|
      # puts "Matching #{theater} with #{name}"
      r = Regexp.new(theater, 'i')
      if r.match(name)
        if message.empty?
          message << "<p> <a href=\"#{website[:url]}\">BookMyShow</a> </p>"
        end
        message << "<div>" << name << "</div>"
      end
    end
  end

  if !message.empty?
    puts "Sending email about: "
    puts message
    send_email(message)
  else
    puts "Nothing found"
  end
end


while true
  # puts check(JUSTICKETS)
  puts "Started at #{Time.now}"
  check(BOOKMYSHOW)
  puts "Ended at #{Time.now}"
  puts "... sleeping for #{INTERVAL} seconds\n\n"
  sleep INTERVAL
end
