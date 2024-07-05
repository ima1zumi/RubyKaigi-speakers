require 'nokogiri'

# NOTE: 新しい方に合わせる
def unify(name)
  case name
  when "SHIBATA Hiroshi"
    "Hiroshi SHIBATA"
  when "TAGOMORI \"moris\" Satoshi", "tagomoris", "Satoshi \"moris\" Tagomori"
    "Satoshi Tagomori"
  when "Thomas E. Enebo"
    "Thomas E Enebo"
  when "Haruka Iwao"
    "Emma Haruka Iwao"
  when "YUKI TORII"
    "Yuki Torii"
  when "Yukihiro Matsumoto"
    "Yukihiro \"Matz\" Matsumoto"
  when "MayumiI EMORI(emorima)"
    "Mayumi EMORI"
  when "Kouhei Sutou"
    "Sutou Kouhei"
  when "moro"
    "Kyosuke MOROHASHI"
  when "Kakutani Shintaro"
    "Shintaro Kakutani"
  when "Toshiaki KOSHIBA"
    "Toshiaki Koshiba"
  when "Aaron Patterson (tenderlove)"
    "Aaron Patterson"
  when "Tomoyuki Chikanaga"
    "nagachika"
  when "Akira “akr” Tanaka"
    "Tanaka Akira"
  when "SHIGERU NAKAJIMA"
    "Shigeru Nakajima"
  when "Yugui - Yuki Sonoda"
    "Yugui"
  when "tenderlove"
    "Aaron Patterson"
  when "Shyouhei Urabe", "Urabe Shyouhei"
    "Urabe, Shyouhei"
  else
    name
  end
end

def add_speakers(speakers, year, name, id, title, url)
  speakers[name][year] ||= []
  speakers[name][year] << {
    id: id,
    title: title,
    url: url
  }
end

def get_speakers_since_2022(year, files)
  talks = Hash.new { |h, k| h[k] = {} }
  parsed_html = Nokogiri::HTML.parse(File.open(files.first))

  parsed_html.css('div.m-schedule-item').each do |item|
    names = item.css('span.m-schedule-item-speaker__name').map { |elm| elm.text }
    names.each.with_index do |name, i|
      name = unify(name)
      ids = item.css('span.m-schedule-item-speaker__id').map { |elm| elm.text }
      id = ids[i]
      title = item.css('div.m-schedule-item__title').text.strip
      url = item.css("a.m-schedule-item__inner").attribute("href").value.tr('..', '') # tr For 2024

      add_speakers(talks, year, name, id, title, url)
    end
  end

  talks
end

def get_speakers_2021_takeout(year, files)
  talks = Hash.new { |h, k| h[k] = {} }
  parsed_html = Nokogiri::HTML.parse(File.open(files.first))

  parsed_html.css('div.p-timetable__track').each do |item|
    names = item.css('span.p-timetable__speaker-name').map { |elm| elm.text.strip }
    names.each.with_index do |name, i|
      name = unify(name)
      ids = item.css('span.p-timetable__speaker-sns').map { |elm| elm.text.strip }
      id = ids[i]
      title = item.css('div.p-timetable__talk-title').text.strip
      url = item.css('a').first&.attribute('href')&.value

      add_speakers(talks, year, name, id, title, url)
    end
  end

  talks
end

def get_speakers_2017_to_2020(year, files)
  talks = Hash.new { |h, k| h[k] = {} }
  parsed_html = Nokogiri::HTML.parse(File.open(files.first))

  parsed_html.css('a.schedule-item').each do |item|
    names = item.css('span.schedule-item-speaker__name').map { |elm| elm.text.strip }
    names.each.with_index do |name, i|
      name = unify(name)
      ids = item.css('span.schedule-item-speaker__id').map { |elm| elm.text.strip }
      id = ids[i]
      title = item.css('div.schedule-item__title').text.strip
      url = item.attribute('href').value

      add_speakers(talks, year, name, id, title, url)
    end
  end

  talks
end

def get_speakers_2015_to_2016(year, files)
  talks = Hash.new { |h, k| h[k] = {} }
  parsed_html = Nokogiri::HTML.parse(File.open(files.first))

  parsed_html.css('td.schedule-table__td').each do |item|
    names = item.css('span.schedule-table__name').map { |elm| elm.text.strip }
    names.each.with_index do |name, i|
      name = unify(name)
      ids = item.css('span.schedule-table__id').map { |elm| elm.text.strip }
      id = ids[i]
      title = item.css('div.schedule-table__title').text.strip
      url = item.css('a').first.attribute('href').value

      add_speakers(talks, year, name, id, title, url)
    end
  end

  talks
end

def get_speakers_in_2014(year, files)
  talks = Hash.new { |h, k| h[k] = {} }
  parsed_html = Nokogiri::HTML.parse(File.open(files.first))

  parsed_html.css('td').each do |item|
    names = item.css('p.speakerName').text.strip.gsub(/\[.*\]/, '').split(",").map { |name| name.lstrip }
    names.each do |name|
      name = unify(name)
      id = nil
      title = item.css('a.presentationTitle').text.strip
      url = item.css('a.presentationTitle').attribute('href').value

      add_speakers(talks, year, name, id, title, url)
    end
  end

  talks
end

def get_speakers_in_2013(year, files)
  talks = Hash.new { |h, k| h[k] = {} }
  parsed_html = Nokogiri::HTML.parse(File.open(files.first))

  parsed_html.css('li').each.with_index do |item, i|
    names = item.text.split("\n").last.split(",").map { |name| name.lstrip }
    # NOTE: Speakerと関係ないものを除外
    # TODO: 正規表現にしたい
    names = names.delete_if do |name|
      if name == 'HOME' || name == 'SCHEDULE' || name == 'SPEAKERS' || name == 'FOR ATTENDEES' || name == 'GOODIES' || name == 'SPONSORS'
        true
      else
        false
      end
    end
    # NOTE: 多分2名扱いにならないように統一
    names = ["nagachika"] if names == ["Tomoyuki", "Chikanaga"]

    names.each do |name|
      name = unify(name)
      id = nil
      title = item.css('a').text.gsub(/\n/, '').gsub(/^'/, '').gsub(/'$/, '').strip
      url = item.css('a').attribute('href')&.value

      add_speakers(talks, year, name, id, title, url)
    end
  end

  talks
end

def get_speakers_in_2011(year, files)
  talks = Hash.new { |h, k| h[k] = {} }
  parsed_html = Nokogiri::HTML.parse(File.open(files.first))

  parsed_html.css('td.session').each do |item|
    names = item.css('ul.presenter').text.strip.split("\n").map { |name| name.lstrip if name != '' }.compact
    sessions = item.css('a.tip').map do |elm|
      elm.children.first&.text&.strip
    end
    urls = item.css('a.tip').map do |elm|
      elm.attribute('href').value
    end
    names.each.with_index do |name, i|
      name = unify(name)
      case name
      when "Koichiro Ohba"
        i = 0
      when "Kouji Takao"
        i = 1
      when "okkez"
        i = 0
      when "Sunao Tanabe"
        i = 0
      when "Toshiaki Koshiba"
        i = 0
      when "Shintaro Kakutani"
        i = 0
      when "Hal Seki"
        i = 1
      end

      # NOTE: Matzと角谷さんと島田さんは2回登壇している。島田さんはたまたまうまくいくので、Matzと角谷さんのみ対応
      i = 1 if name == "Yukihiro \"Matz\" Matsumoto" && talks[1] == "Lightweight Ruby"
      i = 0 if name == "Kakutani Shintaro" && talks[0] == "All About RubyKaigi Ecosystem"
      # NOTE: HTMLの構造上取りにくいので直接書き換え
      sessions[i] = "Ruby Ruined My Life." if name == "Aaron Patterson"

      # NOTE: 2011年は複数回登壇している人がいる
      id = nil
      title = sessions[i]
      url = urls[i]

      add_speakers(talks, year, name, id, title, url)
    end
  end

  talks
end

def get_speakers_in_2010(year, files)
  talks = Hash.new { |h, k| h[k] = {} }
  parsed_html = Nokogiri::HTML.parse(File.open(files.first))

  # NOTE: Main Convention HallとConvention Hall 200を本トラックだと解釈する
  parsed_html.css('td.room_hall').each do |item|
    names = item.css('p.speaker').text.strip
    talk = item.css('a.tip').text.strip.split("\n").first
    url = item.css('a.tip').attribute('href').value

    names = names.split(",").first
    names = case names
            when 'Akira Matsuda, Masayoshi Takahashi and others'
              ['Akira Matsuda', 'Masayoshi Takahashi']
            when 'Munjal Budhabhatti And Sudhindra Rao'
              ['Munjal Budhabhatti', 'Sudhindra Rao']
            when 'Kei Hamanaka, Yuichi Saotome'
              ['Kei Hamanaka', 'Yuichi Saotome']
            else
              [names]
            end

    next if names.first&.empty?
    names.each do |name|
      next if name.nil?
      name = unify(name)
      id = nil
      title = talk

      add_speakers(talks, year, name, id, title, url)
    end
  end

  talks
end

def get_speakers_in_2009(year, files)
  talks = Hash.new { |h, k| h[k] = {} }
  parsed_html = Nokogiri::HTML.parse(File.open(files.first))

  parsed_html.css('div.session').each do |item|
    names = item.css('p.speaker').text
    talk = item.css('p.title').children.text
    url = item.css('p.title').children.attribute('href')&.value

    names = names.split(",")
    names = names&.first&.split("、")
    names = names&.first&.split(" and ")

    next if names&.first&.empty? || !names || names == "(Bring your own food/drink)" || names == "(this room will start at 10:00)"
    names.each do |name|
      name = unify(name)
      id = nil
      title = talk

      add_speakers(talks, year, name, id, title, url)
    end
  end

  talks
end

speakers = Hash.new { |h, k| h[k] = {} }
years = Dir.glob('schedule/*/').map { _1.split('/')[1] }

years.each do |year|
  files = Dir.glob("schedule/#{year}/*")
  talks = {}

  case year
  when '2024', '2023', '2022'
    talks = get_speakers_since_2022(year, files)
  when '2021-takeout'
    talks = get_speakers_2021_takeout(year, files)
  when '2020-takeout', '2019', '2018', '2017'
    talks = get_speakers_2017_to_2020(year, files)
  when '2016', '2015'
    talks = get_speakers_2015_to_2016(year, files)
  when '2014'
    talks = get_speakers_in_2014(year, files)
  when '2013'
    talks = get_speakers_in_2013(year, files)
  when '2011'
    talks = get_speakers_in_2011(year, files)
  when '2010'
    talks = get_speakers_in_2010(year, files)
  when '2009'
    talks = get_speakers_in_2009(year, files)
  when '2008'
  when '2007'
  when '2006'
  end

  speakers = speakers.merge(talks) { |_, old, new| old.merge(new) }
end

pp speakers
