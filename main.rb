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
      names.each.with_index do |name, i|
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
      names = names.delete_if do |name|
        if name == 'HOME' || name == 'SCHEDULE' || name == 'SPEAKERS' || name == 'FOR ATTENDEES' || name == 'GOODIES' || name == 'SPONSORS'
          true
        else
          false
        end
      end

      names.each.with_index do |name, i|
        name = unify(name)
        speakers[name][year] = {
          id: nil,
          title: item.css('a').text.strip,
          url: item.css('a').attribute('href')&.value
        }
      end
    end
  end
end

pp speakers
