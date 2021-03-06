# frozen_string_literal: true

require 'open-uri'
require 'nokogiri'
require 'pry'

module WebScrapers
  # http://isonpu.web.fc2.com/other/route100.html
  class Isopu
    attr_reader :route_data

    BASE_URL = 'http://isonpu.web.fc2.com/other/'

    def initialize
      @doc = Nokogiri::HTML(
        URI.open("#{BASE_URL}route100.html"), nil, 'utf-8', &:noblanks
      )
      @current_region = nil
    end

    def scrape
      @route_data = @doc.css('tr').map do |row|
        if region?(row)
          @current_region = row.at('td.auto-style3').text.gsub(/[[:punct:]]/, '')
          nil
        elsif empty_row?(row)
          nil
        else
          parse_route_data(row)
        end
      end.compact
    end

    def write_to_file
      File.write('saitama.json', JSON.pretty_generate({ saitama: route_data }))
    end

    private

    def region?(row)
      !row.at('td.auto-style3').nil?
    end

    def empty_row?(row)
      row.text.gsub(/\W/, '').empty?
    end

    def parse_route_data(row)
      {
        region: @current_region,
        route_name: row.at('td.auto-style4').text[1..],
        kmz: BASE_URL + row.css('a')[0].attribute('href').value,
        gpx: BASE_URL + row.css('a')[1].attribute('href').value
      }
    end
  end
end
