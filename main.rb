require_relative 'lib/speaker'
require_relative 'lib/html_generator'

YEARS = ["2006", "2007", "2008", "2009", "2010", "2011", "2013", "2014", "2015", "2016", "2017", "2018", "2019", "2020-takeout", "2021-takeout", "2022", "2023", "2024", "2025"]

speakers = Speaker.new(YEARS).get_all_speakers
HtmlGenerator.new(speakers, YEARS).generate_all_page
