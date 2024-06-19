require 'open-uri'

uris = [
  'https://rubykaigi.org/2024/schedule/',
  'https://rubykaigi.org/2023/schedule/',
  'https://rubykaigi.org/2022/schedule/',
  'https://rubykaigi.org/2021-takeout/schedule/',
  'https://rubykaigi.org/2020-takeout/schedule/',
  'https://rubykaigi.org/2019/schedule/',
  'https://rubykaigi.org/2018/schedule/',
  'https://rubykaigi.org/2017/schedule/',
  'https://rubykaigi.org/2016/schedule/',
  'https://rubykaigi.org/2015/schedule/',
  'https://rubykaigi.org/2014/schedule/',
  'https://rubykaigi.org/2013/schedule/',
  'https://rubykaigi.org/2011/en/schedule/grid/',
  'https://rubykaigi.org/2010/en/timetable/',
  'https://rubykaigi.org/2009/en/talks/',
  'https://rubykaigi.org/2008/Program_en.html',
  'https://rubykaigi.org/2007/Program-EN.html',
  'https://rubykaigi.org/2006/program.html'
]

uris.each do |uri|
  URI.open(uri) do |response|
    IO.copy_stream(response, "html/#{uri.split('/')[3]}.html")
  end
end
