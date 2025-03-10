require 'open-uri'
require 'fileutils'

class Downloader
  def self.yamls_for(year)
    ["https://raw.githubusercontent.com/ruby-no-kai/rubykaigi-static/master/#{year}/data/speakers.yml", "https://raw.githubusercontent.com/ruby-no-kai/rubykaigi-static/master/#{year}/data/presentations.yml", "https://raw.githubusercontent.com/ruby-no-kai/rubykaigi-static/master/#{year}/data/schedule.yml"]
  end

  YEARS = {
    '2025' => ['https://rubykaigi.org/2025/data/speakers.yml', 'https://rubykaigi.org/2025/data/presentations.yml', 'https://rubykaigi.org/2025/data/schedule.yml'],
    '2024' => ['https://rubykaigi.org/2024/data/speakers.yml', 'https://rubykaigi.org/2024/data/presentations.yml', 'https://rubykaigi.org/2024/data/schedule.yml'],
    '2023' => yamls_for(2023),
    '2022' => yamls_for(2022),
    '2021-takeout' => yamls_for('2021-takeout'),
    '2020-takeout' => yamls_for('2020-takeout'),
    '2019' => yamls_for(2019),
    '2018' => yamls_for(2018),
    '2017' => yamls_for(2017),
    '2016' => yamls_for(2016),
    '2015' => yamls_for(2015),
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
    if uri.end_with?('.yml')
      File.basename(uri)
    else
      filename = uri.match(/(\d{4}-takeout|\d{4})\/(.*html)/)[2]
      filename.gsub('/', '_')
    end
  end
end

Downloader.download_files
