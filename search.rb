require 'rubygems'
require 'matrix'
require 'tf-idf-similarity'
require 'lingua/stemmer'
require 'fileutils'

class Search

  def initialize()
    @corpus = create_corpus()
    # @matrix = create_matrix()
  end

  def create_matrix()
    paths = Dir['stemming_docs/*/*/']
    corpus = paths.map {|path| TfIdfSimilarity::Document.new(File.open([path, "content.txt"].join("/"), 'r'){|f| f.read})}
    model = TfIdfSimilarity::TfIdfModel.new(corpus)
    matrix = model.similarity_matrix
  end

  def create_corpus()
    paths = Dir['stemming_docs/*/*/']
    @urls_hashs = []
    corpus = paths.map do |path|
      tf_doc = TfIdfSimilarity::Document.new(File.open([path, "content.txt"].join("/"), 'r'){|f| f.read})
      url = File.open([path, "links.txt"].join("/"), 'r'){|f| f.read}
      @urls_hashs << {"tf_doc"=>tf_doc, "url"=>url}
      tf_doc
    end
  end


  def get_result(search_line, count_urls = nil)
    count_urls ||= 3
    tf_search = TfIdfSimilarity::Document.new(search_line.downcase)
    new_corpus = [tf_search, @corpus].flatten
    model = TfIdfSimilarity::TfIdfModel.new(new_corpus)
    matrix = model.similarity_matrix
    result_hashs = @urls_hashs.map do |url_hash|
      point = matrix[model.document_index(tf_search), model.document_index(url_hash['tf_doc'])]
      {
        "point" => point,
        "url" => url_hash['url']
      }
    end
    result_hashs.sort_by{|h| h['point']}.uniq {|h| h['url'] }.first(count_urls).each do |h|
      puts h['url']
    end
  end
end


# puts Search.get_result("wikipedia", 15)

search = Search.new
puts 'Start search'
loop do
  puts "Enter request"
  data = gets
  search.get_result(data.delete("\n"))
end