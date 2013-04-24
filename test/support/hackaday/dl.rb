#!/usr/bin/env ruby
(1..40).map do |i|
  system("wget -O file_#{i}.html http://hackaday.com/page/#{i}/")
end
