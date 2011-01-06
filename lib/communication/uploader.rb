module Communication
  class Uploader
    def self.upload(url, document_path)
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      data = "content=#{URI.escape(File.read(document_path))}"
      http.post(uri.path, data)
    end
  end
end