# frozen_string_literal: true

require_relative '../support/vcr_setup'
require_relative '../../lib/web_scrapers/isopu'

describe WebScrapers::Isopu do
  describe '#scrape' do
    it 'collects route region data' do
      VCR.use_cassette('isopu-saitama-routes') do
        scraper = described_class.new
        expected_regions = %w[利根 東部 県央 南部南西部 川越 比企 西部 北部 本庄 秩父 おまけ]

        scraper.scrape
        scraped_regions = scraper.route_data.map { |route| route[:region] }.uniq

        expect(scraped_regions).to eq(expected_regions)
      end
    end

    it 'collects route name data' do
      VCR.use_cassette('isopu-saitama-routes') do
        scraper = described_class.new
        sample_routes = [
          '01 川沿いを走る日本一長いサイクリングロード',
          '23 越谷の今昔を巡るルート',
          '31 桶川・田園と川のルート',
          '18 新河岸川の自然歴史を訪ねるルート',
          '40 ゆず香る歴史の道元気ルート',
          '53 ときがわ景観ルート',
          '60 狭山ふれあいルート',
          '82 寄居・日本（やまと）の里ルート',
          '90 上里町歴史めぐりルート',
          '100 小鹿野歌舞伎・龍勢を回るルート'
        ]

        scraper.scrape
        scraped_routes = scraper.route_data.map { |route| route[:route_name] }

        expect(scraped_routes).to include(*sample_routes)
      end
    end

    it 'collects route kmz data' do
      VCR.use_cassette('isopu-saitama-routes') do
        scraper = described_class.new
        sample_kmz = [
          'http://isonpu.web.fc2.com/other/cycle/01_kawazoi-nihonichi.kmz',
          'http://isonpu.web.fc2.com/other/cycle/23_koshigaya-konjaku.kmz',
          'http://isonpu.web.fc2.com/other/cycle/31_okegawa-kawa.kmz',
          'http://isonpu.web.fc2.com/other/cycle/18_shingashigawa.kmz',
          'http://isonpu.web.fc2.com/other/cycle/40_yuzu-genki.kmz',
          'http://isonpu.web.fc2.com/other/cycle/53_Tokigawa-keikan.kmz',
          'http://isonpu.web.fc2.com/other/cycle/60_sayama-fureai.kmz',
          'http://isonpu.web.fc2.com/other/cycle/82_yorii-yamato.kmz',
          'http://isonpu.web.fc2.com/other/cycle/90_kamisato-rekishi.kmz',
          'http://isonpu.web.fc2.com/other/cycle/100_ogano-ryusei.kmz'
        ]

        scraper.scrape
        scraped_kmz = scraper.route_data.map { |route| route[:kmz] }

        expect(scraped_kmz).to include(*sample_kmz)
      end
    end

    it 'collects route gpx data' do
      VCR.use_cassette('isopu-saitama-routes') do
        scraper = described_class.new
        sample_gpx = [
          'http://isonpu.web.fc2.com/other/cycle/gpx/01_kawazoi-nihonichi.gpx',
          'http://isonpu.web.fc2.com/other/cycle/gpx/23_koshigaya-konjaku.gpx',
          'http://isonpu.web.fc2.com/other/cycle/gpx/31_okegawa-kawa.gpx',
          'http://isonpu.web.fc2.com/other/cycle/gpx/18_shingashigawa.gpx',
          'http://isonpu.web.fc2.com/other/cycle/gpx/40_yuzu-genki.gpx',
          'http://isonpu.web.fc2.com/other/cycle/gpx/53_Tokigawa-keikan.gpx',
          'http://isonpu.web.fc2.com/other/cycle/gpx/60_sayama-fureai.gpx',
          'http://isonpu.web.fc2.com/other/cycle/gpx/82_yorii-yamato.gpx',
          'http://isonpu.web.fc2.com/other/cycle/gpx/90_kamisato-rekishi.gpx',
          'http://isonpu.web.fc2.com/other/cycle/gpx/100_ogano-ryusei.gpx'
        ]

        scraper.scrape
        scraped_gpx = scraper.route_data.map { |route| route[:gpx] }

        expect(scraped_gpx).to include(*sample_gpx)
      end
    end
  end
end
