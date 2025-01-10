require 'nokogiri'
require 'yaml'
require_relative 'speaker_normalizer'

class Speaker
  def initialize(years)
    @years = years
    @speakers = {}
  end

  def add_speakers(talks, year, name, id, title, url)
    talks[name][year] ||= []
    talks[name][year] << {
      id: id,
      title: title,
      url: url
    }
  end

  def get_speakers_in_2014(year, files)
    talks = Hash.new { |h, k| h[k] = {} }
    parsed_html = Nokogiri::HTML.parse(File.open(files.first))

    parsed_html.css('td').each do |item|
      names = item.css('p.speakerName').text.strip.gsub(/\[.*\]/, '').split(",").map { |name| name.lstrip }
      names.each do |name|
        name = SpeakerNormalizer.unify(name)
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

    not_names = ['HOME', 'SCHEDULE', 'SPEAKERS', 'FOR ATTENDEES', 'GOODIES', 'SPONSORS', 'Team', '(Hall B will start at 10:30am today)']

    parsed_html.css('li').each.with_index do |item, i|
      names = item.text.split("\n").last.split(",").map { |name| name.lstrip }
      # NOTE: Speakerと関係ないものを除外
      names = names.delete_if { |name| not_names.include?(name) }

      # NOTE: 2名扱いにならないように統一
      names = ["nagachika"] if names == ["Tomoyuki", "Chikanaga"]
      names = ["Kyosuke MOROHASHI"] if names == ["moro", "Kyosuke MOROHASHI"]

      names.each do |name|
        next if name.empty?
        name = SpeakerNormalizer.unify(name)
        id = nil
        title = item.css('a').text.gsub(/\n/, '').gsub(/^'/, '').gsub(/'$/, '').strip
        url = item.css('a').attribute('href')&.value

        next if title.empty?

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
        name = SpeakerNormalizer.unify(name)
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
        name = SpeakerNormalizer.unify(name)
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

      next if names&.first&.empty? || !names
      names.each do |name|
        next if name == "(Bring your own food/drink)" || name == "(this room will start at 10:00)"
        name = SpeakerNormalizer.unify(name.strip)
        id = nil
        title = talk
        title = 'あらためて仕事で使うRuby' if name == 'Kentaro Goto / ごとけん' && title == '(TBA)'
        title = 'ビジネスユースでのRuby導入のポイントと解決策' if name == 'Katsutoshi Kojima' && title == '(TBA)'
        title = '実戦投入Rails - RubyKaigiEdition' if name == 'Kazuya Yoshimi' && title == '(TBA)'
        title = 'Railsサイト安定運用の心構え ~8つのサービスから学ぶ' if name == 'Hirotomo Oi' && title == '(TBA)'

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
          name = SpeakerNormalizer.unify(name)
          id = nil
          url = file == 'schedule/2008/MainSession_en.html' ? '/2008/MainSession.html' : '/2008/SubSession.html'

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
          name = SpeakerNormalizer.unify(name)
          id = nil
          url = file.split('schedule')[1]

          add_speakers(talks, year, name, id, title, url)
        end
      end
    end

    talks
  end

  def get_speakers_in_2006(year, files)
    not_talks = ['パネリスト', 'コメンテータ', '司会']

    talks = Hash.new { |h, k| h[k] = {} }
    files.each do |file|
      parsed_html = Nokogiri::HTML.parse(File.open(file))
      parsed_html.css('h4').each do |item|
        heading = item.text.strip
        next if not_talks.include?(heading)
        title = heading.match(/「(.*)」/)[1]
        name = heading.split('「')[0].tr('基調講演:', '').lstrip.rstrip

        name = SpeakerNormalizer.unify(name)
        id = nil
        url = file.split('schedule')[1]

        add_speakers(talks, year, name, id, title, url)
      end
    end

    talks
  end

  def get_speakers_from_yaml(year)
    speakers_yml = YAML.load_file(File.expand_path("schedule/#{year}/speakers.yml"))
    speaker_id_to_name = speakers_yml.values.inject(:merge)
    speaker_id_to_name.each {|k, v| speaker_id_to_name[k] = v['name'] }

    presentations_yml = YAML.load_file(File.expand_path("schedule/#{year}/presentations.yml"))
    talk_id_to_title = presentations_yml.filter_map {|k, v| [k, v['title']] if v.is_a? Hash }.to_h
    speaker_id_to_speaker_ids = presentations_yml.filter_map {|k, v| [k, v['speakers']&.map { it.values.last }] if v.is_a? Hash }.to_h

    Hash.new { |h, k| h[k] = {} }.tap do |talks|
      schedule_yml = YAML.load_file(File.expand_path("schedule/#{year}/schedule.yml"))
      schedule_yml.each_value.with_index(1) do |schedule_per_day, day|
        schedule_per_day['events'].filter_map { it['talks']&.values }.flatten.each do |talk_id|
          title = talk_id_to_title[talk_id]
          url =
            if year.to_i == 2015
              "/#{year}/presentations/#{talk_id}"
            elsif year == '2018'
              "/#{year}/presentations/#{talk_id}.html##{[nil, 'may31', 'jun01', 'jun02'][day]}"
            elsif year == '2019'
              "/#{year}/presentations/#{talk_id}.html#apr#{day + 17}"
            elsif year == '2020-takeout'
              "/#{year}/presentations/#{talk_id}.html#sep0#{day + 3}"
            elsif year.to_i >= 2022
              "/#{year}/presentations/#{talk_id}.html#day#{day}"
            else
              "/#{year}/presentations/#{talk_id}.html"
            end

          if speaker_id_to_speaker_ids[talk_id].nil?
            name = presentations_yml[talk_id]['speaker']
            name = SpeakerNormalizer.unify(name)
            add_speakers(talks, year, name, talk_id, title, url)
          else
            speaker_id_to_speaker_ids[talk_id].each do |speaker_id|
              name = speaker_id_to_name[speaker_id]
              name = SpeakerNormalizer.unify(name)
              add_speakers(talks, year, name, speaker_id, title, url)
            end
          end
        end
      end
    end
  end

  def get_all_speakers
    @years.each do |year|
      files = Dir.glob("schedule/#{year}/*")
      talks = {}

      talks =
        if File.exist?(File.expand_path("schedule/#{year}/speakers.yml"))
          get_speakers_from_yaml(year)
        else
          case year
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
        end

      @speakers = @speakers.merge(talks) { |_, old, new| old.merge(new) }
    end

    @speakers
  end
end
