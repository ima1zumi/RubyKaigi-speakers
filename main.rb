require_relative 'lib/speaker'
require_relative 'lib/html_generator'

YEARS = ["2026", "2025", "2024", "2023", "2022", "2021-takeout", "2020-takeout", "2019", "2018", "2017", "2016", "2015", "2014", "2013", "2011", "2010", "2009", "2008", "2007", "2006"]

speakers = Speaker.new(YEARS).get_all_speakers
HtmlGenerator.new(speakers, YEARS).generate_all_page
