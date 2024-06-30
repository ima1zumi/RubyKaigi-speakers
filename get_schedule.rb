require 'open-uri'

years = {
  '2024' => ['https://rubykaigi.org/2024/schedule/index.html'],
  '2023' => ['https://raw.githubusercontent.com/ruby-no-kai/rubykaigi-static/master/2023/schedule/index.html'],
  '2022' => ['https://raw.githubusercontent.com/ruby-no-kai/rubykaigi-static/master/2022/schedule/index.html'],
  '2021-takeout' => ['https://raw.githubusercontent.com/ruby-no-kai/rubykaigi-static/master/2021-takeout/schedule/index.html'],
  '2020-takeout' => ['https://raw.githubusercontent.com/ruby-no-kai/rubykaigi-static/master/2020-takeout/schedule/index.html'],
  '2019' => ['https://raw.githubusercontent.com/ruby-no-kai/rubykaigi-static/master/2019/schedule/index.html'],
  '2018' => ['https://raw.githubusercontent.com/ruby-no-kai/rubykaigi-static/master/2018/schedule/index.html'],
  '2017' => ['https://raw.githubusercontent.com/ruby-no-kai/rubykaigi-static/master/2017/schedule/index.html'],
  '2016' => ['https://raw.githubusercontent.com/ruby-no-kai/rubykaigi-static/master/2016/schedule/index.html'],
  '2015' => ['https://raw.githubusercontent.com/ruby-no-kai/rubykaigi-static/master/2015/schedule/index.html'],
  '2014' => ['https://raw.githubusercontent.com/ruby-no-kai/rubykaigi-static/master/2014/schedule/index.html'],
  '2013' => ['https://raw.githubusercontent.com/ruby-no-kai/rubykaigi-static/master/2013/schedule/index.html'],
  '2011' => ['https://raw.githubusercontent.com/ruby-no-kai/rubykaigi-static/master/2011/en/schedule/grid/index.html'],
  '2010' => ['https://raw.githubusercontent.com/ruby-no-kai/rubykaigi-static/master/2010/en/timetable/index.html'],
  '2009' => ['https://raw.githubusercontent.com/ruby-no-kai/rubykaigi-static/master/2009/en/talks/index.html'],
  '2008' => ['https://raw.githubusercontent.com/ruby-no-kai/rubykaigi-static/master/2008/MainSession_en.html', 'https://raw.githubusercontent.com/ruby-no-kai/rubykaigi-static/master/2008/SubSession_en.html'],
  '2007' => ['https://raw.githubusercontent.com/ruby-no-kai/rubykaigi-static/master/2007/Program-EN.html'],
  '2006' => ['https://raw.githubusercontent.com/ruby-no-kai/rubykaigi-static/master/2006/program.html']
}

years.each do |year, uris|
  Dir.mkdir("schedule/#{year}") unless Dir.exist?("schedule/#{year}")
  uris.each do |uri|
    URI.open(uri) do |response|
      filename = uri.match(/(\d{4}-takeout|\d{4})\/(.*html)/)[2]
      filename.gsub!('/', '_')
      IO.copy_stream(response, "schedule/#{year}/#{filename}")
    end
  end
end
