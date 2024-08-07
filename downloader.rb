require 'open-uri'
require 'fileutils'

class Downloader
  YEARS = {
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
    '2007' => ['https://raw.githubusercontent.com/ruby-no-kai/rubykaigi-static/master/2007/Program-EN0609.html', 'https://raw.githubusercontent.com/ruby-no-kai/rubykaigi-static/master/2007/Program-EN0610.html'],
    '2006' => ['https://raw.githubusercontent.com/ruby-no-kai/rubykaigi-static/master/2006/program0610.html', 'https://raw.githubusercontent.com/ruby-no-kai/rubykaigi-static/master/2006/program0611.html']
  }

  def self.download_files
    YEARS.each do |year, uris|
      path = "schedule/#{year}"
      FileUtils.mkdir_p(path) unless File.exist?(path)

      uris.each do |uri|
        download_file(uri, path)
      end
    end
  end

  def self.download_file(uri, path)
    URI.open(uri) do |response|
      filename = extract_filename(uri)
      IO.copy_stream(response, "#{path}/#{filename}")
    end
  end

  def self.extract_filename(uri)
    filename = uri.match(/(\d{4}-takeout|\d{4})\/(.*html)/)[2]
    filename.gsub('/', '_')
  end
end

Downloader.download_files
