require 'nokogiri'

class Speaker
  def initialize(name, id = '')
    @name = SpeakerNormalizer.unify(name)
    @id = id # TODO: implement unify id
    @talks = []
  end

  def add_talk(talk)
    @talks << talk
  end
end

class Talk
  def initialize(title, url)
    @title = title
    @url = url
  end
end

class Scraper
  def initialize(year, files)
    @year = year
    @files = files
  end

  def scrape
    parsed_htmls = @files.map { |file| Nokogiri::HTML(File.read(file)) }
    parse_htmls(parsed_htmls)
  end

  private

  def parse_htmls(parsed_htmls, speakers)
    case @year
    when '2024', '2023', '2022'
      get_speakers_since_2022(year, parsed_htmls)
    when '2021-takeout'
      get_speakers_in_2021_takeout(year, parsed_htmls)
    when '2020-takeout', '2019', '2018', '2017'
      get_speakers_2017_to_2020(year, parsed_htmls)
    when '2016', '2015'
      get_speakers_2015_to_2016(year, parsed_htmls)
    when '2014'
      get_speakers_in_2014(year, parsed_htmls)
    when '2013'
      get_speakers_in_2013(year, parsed_htmls)
    when '2011'
      get_speakers_in_2011(year, parsed_htmls)
    when '2010'
      get_speakers_in_2010(year, parsed_htmls)
    when '2009'
      get_speakers_in_2009(year, parsed_htmls)
    when '2008'
      get_speakers_in_2008(year, parsed_htmls)
    when '2007'
      get_speakers_in_2007(year, parsed_htmls)
    when '2006'
      get_speakers_in_2006(year, parsed_htmls)
    else
      {}
    end
  end

  # TODO: read yml file
  def get_speakers_since_2022(year, parsed_htmls)
    talks = Hash.new { |h, k| h[k] = {} }

    parsed_htmls.each do |parsed_html|
      parsed_html.css('div.m-schedule-item').each do |item|
        names = item.css('span.m-schedule-item-speaker__name').map { |elm| elm.text }
        names.each.with_index do |name, i|
          next if name.strip.empty?
          name = SpeakerNormalizer.unify(name)
          ids = item.css('span.m-schedule-item-speaker__id').map { |elm| elm.text }
          id = ids[i]
          title = item.css('div.m-schedule-item__title').text.strip
          if year == '2024'
            url = '/2024' + item.css("a.m-schedule-item__inner").attribute("href").value.gsub(/\.\./, '')
          else
            url = item.css("a.m-schedule-item__inner").attribute("href").value
          end

          next if name == "CRuby Committers"
          add_speakers(talks, year, name, id, title, url)
        end
      end

      talks
    end
  end
end
