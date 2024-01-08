require 'nokogiri'

# NOTE: 新しい方に合わせる
def unify(name)
  case name
  when "SHIBATA Hiroshi"
    "Hiroshi SHIBATA"
  when "TAGOMORI \"moris\" Satoshi"
    "Satoshi \"moris\" Tagomori"
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
  else
    name
  end
end

speakers = Hash.new { |h, k| h[k] = {} }
htmls = Dir.glob('html/*.html')

htmls.each do |html|
  parsed_html = Nokogiri::HTML.parse(File.open(html))
  year = html.split('/')[-1].split('.')[0].to_sym

  if year == :'2023' || year == :'2022'
    parsed_html.css('div.m-schedule-item').each do |item|
      names = item.css('span.m-schedule-item-speaker__name').map { |elm| elm.text }
      names.each.with_index do |name, i|
        name = unify(name)
        ids = item.css('span.m-schedule-item-speaker__id').map { |elm| elm.text }
        speakers[name][year] = {
          id: ids[i],
          title: item.css('div.m-schedule-item__title').text.strip,
          url: item.css("a.m-schedule-item__inner").attribute("href").value
        }
      end
    end
  elsif year == :'2021-takeout'
    parsed_html.css('div.p-timetable__track').each do |item|
      names = item.css('span.p-timetable__speaker-name').map { |elm| elm.text.strip }
      names.each.with_index do |name, i|
        name = unify(name)
        ids = item.css('span.p-timetable__speaker-sns').map { |elm| elm.text.strip }
        speakers[name][year] = {
          id: ids[i],
          title: item.css('div.p-timetable__talk-title').text.strip,
          url: item.css('a').first&.attribute('href')&.value
        }
      end
    end
  elsif year == :'2020-takeout' || year == :'2019' || year == :'2018' || year == :'2017'
    parsed_html.css('a.schedule-item').each do |item|
      names = item.css('span.schedule-item-speaker__name').map { |elm| elm.text.strip }
      names.each.with_index do |name, i|
        name = unify(name)
        ids = item.css('span.schedule-item-speaker__id').map { |elm| elm.text.strip }
        speakers[name][year] = {
          id: ids[i],
          title: item.css('div.schedule-item__title').text.strip,
          url: item.attribute('href').value
        }
      end
    end
  elsif year == :'2016' || year == :'2015'
    parsed_html.css('td.schedule-table__td').each do |item|
      names = item.css('span.schedule-table__name').map { |elm| elm.text.strip }
      names.each.with_index do |name, i|
        name = unify(name)
        ids = item.css('span.schedule-table__id').map { |elm| elm.text.strip }
        speakers[name][year] = {
          id: ids[i],
          title: item.css('div.schedule-table__title').text.strip,
          url: item.css('a').first.attribute('href').value
        }
      end
    end
  elsif year == :'2014'
    parsed_html.css('td').each do |item|
      names = item.css('p.speakerName').text.strip.gsub(/\[.*\]/, '').split(",").map { |name| name.lstrip }
      names.each do |name|
        name = unify(name)
        speakers[name][year] = {
          id: nil,
          title: item.css('a.presentationTitle').text.strip,
          url: item.css('a.presentationTitle').attribute('href').value
        }
      end
    end
  elsif year == :'2013'
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

      names.each do |name|
        name = unify(name)
        speakers[name][year] = {
          id: nil,
          # TODO: 正規表現をまとめたい
          title: item.css('a').text.gsub(/\n/, '').gsub(/^'/, '').gsub(/'$/, '').strip,
          url: item.css('a').attribute('href')&.value
        }
      end
    end
  elsif year == :'2011'
    parsed_html.css('td.session').each do |item|
      names = item.css('ul.presenter').text.strip.split("\n").map { |name| name.lstrip if name != '' }.compact
      talks = item.css('a.tip').map do |elm|
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
        talks[i] = "Ruby Ruined My Life." if name == "Aaron Patterson"

        speakers[name][year] ||= []
        speakers[name][year] << {
          id: nil,
          title: talks[i],
          url: urls[i]
        }
      end
    end
  end
end

pp speakers
