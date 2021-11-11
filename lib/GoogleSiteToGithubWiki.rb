require "GoogleSiteToGithubWiki/version"
require 'html2markdown'
require 'nokogiri'
require 'find'
require 'fileutils'

module GoogleSiteToGithubWiki
  class Error < StandardError; end
  class Converter
    attr_accessor :source_path, :opts
    attr_reader :output_path, :file_paths, :page_paths
    def initialize(source_dir_path, output_dir_path, opts = {})
      @source_path = source_dir_path
      @page_paths = []
      @file_paths = []
      @output_path = output_dir_path
      @opts = { 
                fall_back_content_selector: 'body', 
                content_selector:           '.sites-layout-name-one-column' 
              }.merge(opts)
      @folders = {}
      @page_collected = false
    end
  
    def convert!
      process_page_paths!
      process_file_paths!
      process_sidebars! if opts[:create_sidebars]
    end
  
    def collect_page_paths_and_file_paths!
      Find.find(source_path).each do |path|
        if is_html?(path)
          collect_page_paths(path)
          add_file_to_sidebar(path)
        else
          collect_file_paths(path)
        end
      end
      @page_collected = true
    end
  
    private 
    def process_page_paths!
      collect_page_paths_and_file_paths! if need_to_collect_pages?
      self.page_paths.each do |path|
        md = convert_page_to_markdown(path)
        verify_folder_exists(path)
        File.write(destination_markdown(path), md)
      end
    end
    
    def process_sidebars!
      collect_page_paths_and_file_paths! if need_to_collect_pages?
      @folders.each do |folder, pages|
        File.write(folder + '/_Sidebar.md', sidebar_content(folder, pages))
      end
    end
  
    def sidebar_content(folder, pages)
      title = clean(File.basename(folder)) unless folder == output_path
      "#{title}\n" + pages.map do |page|
        "* [#{clean(page)}](#{page})"
      end.join("\n")
    end
  
    def clean(word)
      word.gsub(/\-/, ' ').capitalize
    end
  
    def need_to_collect_pages?
      !@page_collected
    end
  
    def process_file_paths!
      collect_page_paths_and_file_paths! if need_to_collect_pages?
      self.file_paths.each do |path|
        verify_folder_exists(path)
        begin
          FileUtils.cp(path, destination_file(path)) unless File.directory?(path)
        rescue => e
          debug("process_file_paths! path:") { path }
          debug("process_file_paths! destination_file(path):") { path }
          raise e
        end
      end
    end
  
    def verify_folder_exists(page)
      FileUtils.mkdir_p(File.dirname(destination_file(page))) 
    end
  
    def add_file_to_sidebar(page)
      @folders[File.dirname(destination_file(page))] ||= []
      @folders[File.dirname(destination_file(page))] << File.basename(page, '.html')
    end
  
    def convert_page_to_markdown(page)
      doc = Nokogiri::HTML(open(page))
      contents = doc.at_css(opts[:content_selector])
      if contents.nil?
        debug ('Content not found for ' + page + ' Converting whole page')
        contents = doc.at_css(opts[:fall_back_content_selector])
      end
      contents.css('a').each do |link|
        if link[:href] =~ /\.html$/ && !(link[:href] =~ /\?/)
          link[:href] = File.basename(link[:href], '.html')
        end
      end
      contents = contents.send(:inner_html)
      filename = File.basename(page, '.html')
      replace = page.sub(/^#{source_path}(\/)?/, '').gsub(/\.html$/, '/')
      md = HTMLPage.new(contents: contents).markdown.gsub(/(#{filename}\/)/, replace)
    end
  
    def is_html?(path)
      File.extname(path) =~ /\.html$/i
    end
  
    def collect_file_paths(path)
      @file_paths << path
    end

    def collect_page_paths(path)
      @page_paths << path
    end
  
    def destination_markdown(page)
      destination_file(page).sub(/(html)$/, 'md')
    end
  
    def destination_file(page)
      if opts[:replace_page_paths][File.basename(page)]
        debug("replacing #{File.basename(page)} w/ #{opts[:replace_page_paths][File.basename(page)]}") { 
          page.sub!(/(#{File.basename(page)})$/, opts[:replace_page_paths][File.basename(page)])
        }
      else
        page.sub(/^(#{source_path})/, output_path)          
      end
    end

    def is_debug_mode?
      opts[:debug]
    end
  
    def debug(prefix_or_msg = '[debug]')
      if block_given?
        yield.tap { |output|
          puts [prefix_or_msg, output.inspect].join(' ') if is_debug_mode?
        }
      else
        puts prefix_or_msg if is_debug_mode?
      end
    end
  end
end
