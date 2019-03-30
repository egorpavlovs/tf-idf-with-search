require 'rubygems'
require 'matrix'
require 'tf-idf-similarity'
require 'lingua/stemmer'
require 'fileutils'

S_DOCS_HOME_PATH = 'stemming_docs'

class Search

  def self.get_result(request, count_result=nil)
    request = request.split(" ").map{|word| Lingua.stemmer(word)}.join(" ")

    all_paths = Dir["#{S_DOCS_HOME_PATH}/*/*/*"]
    file_with_tf_idf = all_paths.map do |path|
      [path, count_similar(request, path)]
    end
    puts ""
    count_result ||= all_paths.count
    file_with_tf_idf.sort_by(&:last).reverse.first(count_result)
  end

  def self.count_similar(request, doc)
    print "*"

    tf_document_data = TfIdfSimilarity::Document.new(File.open(doc) { |file| file.read })
    tf_document_request = TfIdfSimilarity::Document.new(request)

    corpus = [tf_document_request, tf_document_data]

    model = TfIdfSimilarity::TfIdfModel.new(corpus)

    matrix = model.similarity_matrix
    matrix[model.document_index(tf_document_request), model.document_index(tf_document_data)]
  end
end


puts Search.get_result("wikipedia", 10)