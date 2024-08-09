require_relative 'scraper'

class SpeakerManager
  def initialize
    @speakers = {}
  end

  def load_speakers(years)
    years.each do |year|
      files = Dir.glob("schedule/#{year}/*.html")
      scraper = Scraper.new(year, files)
      speakers = scraper.scrape
      @speakers = @speakers.merge(speakers) { |_, old, new| old.merge(new) }
    end
  end
end
