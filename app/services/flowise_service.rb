class FlowiseService

  def create_document_store(association)
  	begin
	  	require "uri"
			require "json"
			require "net/http"

			url = URI("#{ENV['FLOWISE_SERVER_URL']}/api/v1/document-store/store")

			http = Net::HTTP.new(url.host, url.port);
			request = Net::HTTP::Post.new(url)
			request["Content-Type"] = "application/json"
			request["Authorization"] = "Bearer #{ENV["FLOWISE_KEY"]}"
			request.body = JSON.dump({
			  "name": "#{association.id}-#{association&.name&.downcase}",
			  "description": "Store for internal documents"
			})

			response = http.request(request)
			data = JSON.parse(response.read_body)
			if response.code == "200"
				association.update(flowise_document_store_id: data["id"])
			else
				puts response.read_body
				Rails.logger.info "*******Folder creation error #{data['message']} *******"
			end
  	rescue StandardError => e
			Rails.logger.info "******* #{e.message} *******"
  	end
  end

  # def upload_document_in_document_store(association, uploaded_file)
	#   begin
	#     require "uri"
	#     require "net/http"
	#     require "json"

	#     return unless association.flowise_document_store_id.present?

	#     url = URI("#{ENV['FLOWISE_SERVER_URL']}/api/v1/document-store/#{association.flowise_document_store_id}/documents")

	#     http = Net::HTTP.new(url.host, url.port)
	#     http.use_ssl = (url.scheme == "https")

	#     request = Net::HTTP::Post.new(url)
	#     request["Authorization"] = "Bearer #{ENV['FLOWISE_KEY']}"

	#     file = uploaded_file.tempfile || File.open(uploaded_file.path)

	#     form_data = [
	#       ['files', file]
	#     ]

	#     request.set_form(form_data, 'multipart/form-data')

	#     response = http.request(request)

	#     body = response.body

	#     if response.code == "200"
	#       data = JSON.parse(body)
	#       puts data
	#     else
	#       Rails.logger.error "Upload failed (#{response.code}): #{body}"
	#     end

	#   rescue JSON::ParserError
	#     Rails.logger.error "Non-JSON response received: #{response&.body}"

	#   rescue StandardError => e
	#     Rails.logger.error "Error uploading document: #{e.message}"

	#   ensure
	#     file.close if file && !file.closed?
	#   end
	# end


end
