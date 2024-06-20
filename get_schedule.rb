require 'open-uri'

uris = [
  'https://rubykaigi.org/2024/schedule/',
  'https://raw.githubusercontent.com/ruby-no-kai/rubykaigi-static/master/2023/data/speakers.yml',
  'https://raw.githubusercontent.com/ruby-no-kai/rubykaigi-static/master/2022/data/speakers.yml',
  'https://raw.githubusercontent.com/ruby-no-kai/rubykaigi-static/master/2021-takeout/data/speakers.yml',
  'https://raw.githubusercontent.com/ruby-no-kai/rubykaigi-static/master/2020-takeout/schedule/index.html',
  'https://raw.githubusercontent.com/ruby-no-kai/rubykaigi-static/master/2019/schedule/index.html',
  'https://raw.githubusercontent.com/ruby-no-kai/rubykaigi-static/master/2018/schedule/index.html',
  'https://raw.githubusercontent.com/ruby-no-kai/rubykaigi-static/master/2017/schedule/index.html',
  'https://raw.githubusercontent.com/ruby-no-kai/rubykaigi-static/master/2016/data/speakers.yml',
  'https://raw.githubusercontent.com/ruby-no-kai/rubykaigi-static/master/2015/schedule/index.html',
  'https://raw.githubusercontent.com/ruby-no-kai/rubykaigi-static/master/2014/schedule/index.html',
  'https://raw.githubusercontent.com/ruby-no-kai/rubykaigi-static/master/2013/schedule/index.html',
  'https://raw.githubusercontent.com/ruby-no-kai/rubykaigi-static/master/2011/en/schedule/grid/index.html',
  'https://raw.githubusercontent.com/ruby-no-kai/rubykaigi-static/master/2010/en/timetable/index.html',
  'https://raw.githubusercontent.com/ruby-no-kai/rubykaigi-static/master/2009/en/talks/index.html',
  'https://raw.githubusercontent.com/ruby-no-kai/rubykaigi-static/master/2008/Program_en.html',
  'https://raw.githubusercontent.com/ruby-no-kai/rubykaigi-static/master/2007/Program-EN.html',
  'https://raw.githubusercontent.com/ruby-no-kai/rubykaigi-static/master/2006/program.html'
]

uris.each do |uri|
  URI.open(uri) do |response|
    year = uri.split('/')[3]
    if uri.include?('.yml')
      IO.copy_stream(response, "schedule/#{year}.yml")
    else
      IO.copy_stream(response, "schedule/#{year}.html")
    end
  end
end
