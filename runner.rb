# frozen_string_literal: true

require 'json'
require 'nokogiri'
require 'pry'

module StringRefinements
  refine String do
    def sanitize
      # Interpunct, blank space, full width space
      gsub(/[・\s　]/, '')
    end
  end
end

# Combine multiple KML files and categorize them by region
# TODO: Generalize the routine for any bicycle route
class KmlGenerator
  attr_reader :route_metadata, :out

  using StringRefinements

  REGION_COLOR_LEGEND = {
    利根: 'bf673ab7',
    東部: 'c7ff5722',
    県央: 'ffeb3bbd',
    南部南西部: 'c95027b0',
    川越: 'd903a9f4',
    比企: 'd9f44336',
    西部: 'bd4caf50',
    北部: 'c7009688',
    本庄: 'cf795548',
    秩父: 'd9ffeb3b'
  }.freeze

  def initialize
    @route_metadata = JSON.parse(File.read('saitama.json'), symbolize_names: true)[:saitama]
    @out = Nokogiri::XML::Node.new('kml', Nokogiri::XML::Document.new) do |node|
      node['xmlns'] = 'http://www.opengis.net/kml/2.2'
      node['xmlns:gx'] = 'http://www.google.com/kml/ext/2.2'
      node['xmlns:kml'] = 'http://www.opengis.net/kml/2.2'
      node['xmlns:atom'] = 'http://www.w3.org/2005/Atom'
      node << '<Folder><name>Saitama Prefecture</name></Folder>'
    end
  end

  def run
    add_region_nodes
    add_routes

    @out.write_xml_to(File.new('out.kml', 'w+'), encoding: 'UTF-8')
  end

  private

  def add_region_nodes
    main_node = @out.at('Folder')

    REGION_COLOR_LEGEND.each_key { |region| add_folder_node(region, main_node) }
  end

  def add_routes
    Dir['data/saitama/kml/*.{kml}'].each do |path|
      kml = Nokogiri::XML(File.read(path))
      region_name_node = @out.css('Folder name').find { |node| node.text == region_name(kml) }

      style_route(kml)
      region_name_node.parent << kml.at('Folder')
    end
  end

  def add_folder_node(name, parent_node)
    new_folder = new_node('Folder', parent_node)
    name_node = new_node('name', new_folder, name)

    new_folder << name_node
    parent_node << new_folder
  end

  def new_node(name, parent_node, content = nil)
    Nokogiri::XML::Node.new(name, parent_node) do |node|
      node.content = content
    end
  end

  def style_route(route_kml)
    route_kml.css('color').each do |node|
      node.content = REGION_COLOR_LEGEND[region_name(route_kml).to_sym]
    end
  end

  def region_name(route_kml)
    route_name = route_kml.at('Folder name').text.sanitize
    @route_metadata.find { |route| route[:route_name].sanitize == route_name }[:region]
  end
end
