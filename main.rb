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
  when "Yukihiro Matsumoto", "Yukihiro \"matz\" MATSUMOTO", "まつもとゆきひろ", "Matz"
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
  when "Yugui - Yuki Sonoda", "Yugui (Yuki SONODA)"
    "Yugui"
  when "tenderlove"
    "Aaron Patterson"
  when "Shyouhei Urabe", "Urabe Shyouhei"
    "Urabe, Shyouhei"
  when "Koichi SASADA"
    "Koichi Sasada"
  when "Yui NARUSE"
    "NARUSE, Yui"
  when "Akira TANAKA"
    "Tanaka Akira"
  when "Charles O. Nutter"
    "Charles Nutter"
  when "Thomas Enebo"
    "Thomas E Enebo"
  when "Akio Tajima aka arton"
    "arton"
  when "Yutaka Hara"
    "Yutaka HARA"
  when "関将俊"
    "Masatoshi SEKI"
  when "高橋征義"
    "Masayoshi Takahashi"
  when "田中 哲", "田中哲"
    "Tanaka Akira"
  when "石塚圭樹"
    "Keiju Ishitsuka"
  when "Kentaro GOTO", "後藤謙太郎", "Kentaro Goto", "gotoken"
    "Kentaro Goto / ごとけん"
  when "前田修吾", "Shugo MAEDA"
    "Shugo Maeda"
  else
    name
  end
end

def add_speakers(talks, year, name, id, title, url)
  talks[name][year] ||= []
  talks[name][year] << {
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
      next if name.strip.empty?
      name = unify(name)
      ids = item.css('span.m-schedule-item-speaker__id').map { |elm| elm.text }
      id = ids[i]
      title = item.css('div.m-schedule-item__title').text.strip
      url = item.css("a.m-schedule-item__inner").attribute("href").value.tr('..', '') # tr For 2024

      next if name == "CRuby Committers"
      add_speakers(talks, year, name, id, title, url)
    end
  end

  talks
end

def get_speakers_in_2021_takeout(year, files)
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

      next if name == "CRuby Committers"
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
      next if name.empty?
      name = unify(name)
      ids = item.css('span.schedule-item-speaker__id').map { |elm| elm.text.strip }
      id = ids[i]
      title = item.css('div.schedule-item__title').text.strip
      url = item.attribute('href').value

      next if name == "CRuby Committers" || name == "mame & the judges"

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
      next if name.empty?
      name = unify(name)
      ids = item.css('span.schedule-table__id').map { |elm| elm.text.strip }
      id = ids[i]
      title = item.css('div.schedule-table__title').text.strip
      url = item.css('a').first.attribute('href').value

      next if title == "LT speakers (JA -> EN interpreters won't be available)"
      next if name == "Ruby committers" || name == "@mametter & the judges"
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
      next if name.empty?
      name = unify(name)
      id = nil
      title = item.css('a').text.gsub(/\n/, '').gsub(/^'/, '').gsub(/'$/, '').strip
      url = item.css('a').attribute('href')&.value

      next if title == 'Lightning Talks' || title == "TRICK (Transcendental Ruby Imbroglio Contest for rubyKaigi)"

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
      i = 1 if name == "Yukihiro \"Matz\" Matsumoto" && sessions[1] == "Lightweight Ruby"
      i = 0 if name == "Kakutani Shintaro" && sessions[0] == "All About RubyKaigi Ecosystem"
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

def get_speakers_in_2008(year, files)
  not_talks = ['Opening', 'Doors open', 'Ruby スポンサー', 'Platinum スポンサー', 'Gold スポンサー', 'メディアスポンサー', '協力']
  talks = Hash.new { |h, k| h[k] = {} }

  files.map do |file|
    # NOTE: 2008年はcharsetがEUC-JPでFile.openするとパースできない。File.readだとパースできる
    parsed_html = Nokogiri::HTML.parse(File.read(file))
    parsed_html.css('h4').each do |item|
      heading = item.text.strip
      next if not_talks.include?(heading)

      title = heading.rpartition('-')[0].rstrip
      names = heading.rpartition('-')[2].gsub(/\[English\]/, '').gsub(/,.*/, '').strip.split("/")

      names.each do |name|
        name = unify(name)
        id = nil
        url = file == 'schedule/2008/MainSession_en.html' ? 'https://rubykaigi.org/2008/MainSession.html' : 'https://rubykaigi.org/2008/SubSession.html'

        add_speakers(talks, year, name, id, title, url)
      end
    end
  end

  talks
end

def get_speakers_in_2007(year, files)
  not_talks = ['特別協賛', '協賛', '技術協力']
  keynotes = {'The Keynote for RubyKaigi 2007' => 'Yukihiro "Matz" Matsumoto', 'Island Ruby, orHow To Survive Invasions, Immigrants, and Cultural Attacks' => 'Dave Thomas'}
  talks = Hash.new { |h, k| h[k] = {} }

  files.each do |file|
    parsed_html = Nokogiri::HTML.parse(File.open(file))
    parsed_html.css('h4').each do |item|
      heading = item.text.strip
      next if not_talks.include?(heading)

      title = heading[/.*(?=\()/]&.rstrip || heading
      names = heading.split('(')[1]&.gsub(/\)/, '')&.split("/")&.map(&:strip)
      if names.nil?
        names = [keynotes[title]]
      end

      # NOTE: 取りにくいので直接書き換え
      case title
      when "Windows GUI Development with Project 'VisualuRuby' (nyasu"
        title = "Windows GUI Development with Project 'VisualuRuby'"
        names = ['nyasu (NISHIKAWA Yasuhiro)']
      when 'YAR(V)I: Yet Another Ruby(on VM) Implementations'
        names = ['Akio Tajima aka arton']
      when 'AP4R : Asynchronous Messaging Library for Ruby'
        names = ["Shun'ichi Shinohara", 'Kiwamu Kato']
      end

      names.each do |name|
        name = unify(name)
        id = nil
        url = file

        add_speakers(talks, year, name, id, title, url)
      end
    end
  end

  talks
end

def get_speakers_in_2006(year, files)
  not_talks = ['パネリスト', 'コメンテータ', '司会']
  lightning_talks = ['BioRuby', 'RubyCocoaで作るMacアプリケーション', 'RubyによるHL7プロトコルライブラリ', 'Ruby On Rails の Relative Path プラグイン', 'Rails製CMS「Rubricks」', 'わりと簡単rubyアプリをDebianへ', 'Ruby on 風博士', 'なぜブロックは素晴らしいか -- RubyがLispでない理由', 'Ruby Reference Seeker for Emacsen', '人工無能 ロイディ', 'インターネット物理モデル: または私はいかにして悩むのをやめ転がる玉を愛するようになったか']

  talks = Hash.new { |h, k| h[k] = {} }
  files.each do |file|
    parsed_html = Nokogiri::HTML.parse(File.open(file))
    parsed_html.css('h4').each do |item|
      heading = item.text.strip
      next if not_talks.include?(heading)
      title = heading.match(/「(.*)」/)[1]
      name = heading.split('「')[0].strip.tr('基調講演: ', '')
      next if lightning_talks.include?(title)

      name = unify(name)
      id = nil
      url = file

      add_speakers(talks, year, name, id, title, url)
    end
  end

  talks
end

def get_speakers(speakers, years)
  years.each do |year|
    files = Dir.glob("schedule/#{year}/*")
    talks = {}

    talks = case year
    when '2024', '2023', '2022'
      get_speakers_since_2022(year, files)
    when '2021-takeout'
      get_speakers_in_2021_takeout(year, files)
    when '2020-takeout', '2019', '2018', '2017'
      get_speakers_2017_to_2020(year, files)
    when '2016', '2015'
      get_speakers_2015_to_2016(year, files)
    when '2014'
      get_speakers_in_2014(year, files)
    when '2013'
      get_speakers_in_2013(year, files)
    when '2011'
      get_speakers_in_2011(year, files)
    when '2010'
      get_speakers_in_2010(year, files)
    when '2009'
      get_speakers_in_2009(year, files)
    when '2008'
      get_speakers_in_2008(year, files)
    when '2007'
      get_speakers_in_2007(year, files)
    when '2006'
      get_speakers_in_2006(year, files)
    else
      {}
    end

    speakers = speakers.merge(talks) { |_, old, new| old.merge(new) }
  end

  speakers
end

speakers = Hash.new { |h, k| h[k] = {} }
years = Dir.glob('schedule/*/').map { _1.split('/')[1] }

pp get_speakers(speakers, years)
