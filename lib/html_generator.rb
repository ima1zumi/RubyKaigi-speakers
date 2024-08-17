require 'erb'

class HtmlGenerator
  def initialize(speakers, years)
    @speakers = speakers
    @years = years
  end

  def generate_all_page
    create_html(@speakers)
    create_html_each_year(@speakers)
    create_html_each_speaker(@speakers)
  end

  def generate(talks, output_path)
    template = File.read("lib/index.html.erb")
    result = ERB.new(template).result(binding)
    File.write("#{output_path}index.html", result)
  end

  def create_html(speakers, path = '')
    talks = speakers.map do |name, talks|
      talks.map do |year, talks|
        talks.map do |talk|
          url = "<a href='https://rubykaigi.org#{talk[:url]}' target='_blank'>#{talk[:title]}</a>"
          [year, name, url]
        end
      end
    end.flatten(2)

    generate(talks, path)
  end

  def create_html_each_year(speakers)
    @years.each do |year|
      FileUtils.rm_rf(year) if File.exist?(year)
      FileUtils.mkdir_p(year) unless File.exist?(year)

      result = speakers.each_with_object({}) do |(name, talks), memo|
        memo[name] = { year => talks[year] } if talks[year]
      end

      create_html(result, "#{year}/")
    end
  end

  def create_html_each_speaker(speakers)
    FileUtils.rm_rf('speakers/') if File.exist?('speakers/')
    speakers.each do |talks|
      result = {talks[0] => talks[1]} # {name: {year: [{id:, title:, url:}]}}
      name = URI.encode_www_form_component(talks[0])
      path = "speakers/#{name}"
        FileUtils.mkdir_p(path) unless File.exist?(path)
      create_html(result, "#{path}/")
    end
  end
end
