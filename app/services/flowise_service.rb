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


  def created_document(association)
  	begin
	  	payload = {
			  name: "#{association.name}_#{association.id}",
			  description: "Store for internal documentse",
			  loaders: '[]',
			  whereUsed: '[]',
			  status: 'EMPTY',
			  vectorStoreConfig: '{}',
			  embeddingConfig: '{}',
			  recordManagerConfig: '{}'
			}
			 
			url = URI("#{ENV['FLOWISE_SERVER_URL']}/api/v1/document-store/store")
			http = Net::HTTP.new(url.host, url.port)
			 
			request = Net::HTTP::Post.new(url.path, {
			  'Authorization' => "Bearer #{ENV['FLOWISE_KEY']}",
			  'Content-Type' => 'application/json'
			})

			request.body = payload.to_json
			response = http.request(request)
			 
			unless response.is_a?(Net::HTTPSuccess)
			  Rails.logger.error("Flowise API error: #{response.code} - #{response.body}")
			  raise StandardError, "Failed to create document store"
			end
			 
			result = JSON.parse(response.body)
			document_store_id = result['id']
			 
			 
			test_file_path = Rails.root.join("public", "test.pdf")
			raise "Missing test file at #{test_file_path}" unless File.exist?(test_file_path)
			 
			 
			file = File.open(test_file_path, "rb")
			safe_filename = "test.pdf"
			file_id = SecureRandom.uuid
			 
			 
			boundary = "----RubyMultipartPost#{SecureRandom.hex(10)}"
			post_body = []
			 
			 
			def add_form_field(post_body, boundary, name, value)
			  post_body << "--#{boundary}\r\n"
			  post_body << "Content-Disposition: form-data; name=\"#{name}\"\r\n\r\n"
			  post_body << "#{value}\r\n"
			end
			 
			 
			add_form_field(post_body, boundary, "loader", {
			  name: "pdfFile",
			  config: { usage: "perFile", legacyBuild: false }
			}.to_json)
			 
			add_form_field(post_body, boundary, "splitter", {
			  name: "recursiveCharacterTextSplitter",
			  config: { chunkSize: 2000, chunkOverlap: 200 }
			}.to_json)
			 
			add_form_field(post_body, boundary, "vectorStore", {
			  name: "pinecone",
			  config: {
			    pineconeIndex: "alliv4",
			    pineconeNamespace: "#{association.name.parameterize}-#{association.id}",
			    topK: "5",
			    searchType: "similarity",
			    credential: "#{ENV['PINECONE_CREDENTIAL_ID']}"
			  }
			}.to_json)
			 
			add_form_field(post_body, boundary, "embedding", {
			  name: "openAIEmbeddings",
			  config: {
			    modelName: "text-embedding-3-small",
			    tasktype: "RETRIEVAL_QUERY",
			    credential: "#{ENV['FLOWISE_CREDENTIAL_ID']}"
			  }
			}.to_json)
			 
			add_form_field(post_body, boundary, "metadata", {
			  fileId: file_id,
			  fileName: safe_filename,
			  source: safe_filename,
			  omitMetadata: false
			}.to_json)
			 
			 
			post_body << "--#{boundary}\r\n"
			post_body << "Content-Disposition: form-data; name=\"files\"; filename=\"#{safe_filename}\"\r\n"
			post_body << "Content-Type: application/pdf\r\n\r\n"
			post_body << file.read
			post_body << "\r\n--#{boundary}--\r\n"
			 
			url = URI("#{ENV['FLOWISE_SERVER_URL']}/api/v1/document-store/upsert/#{document_store_id}")
			request = Net::HTTP::Post.new(url)
			request["Authorization"] = "Bearer #{ENV['FLOWISE_KEY']}"
			request["Content-Type"] = "multipart/form-data; boundary=#{boundary}"
			request.body = post_body.join
			http = Net::HTTP.new(url.host, url.port)
			http.open_timeout = 120    # seconds
			http.read_timeout = 600
			upload_response = http.request(request)
			 
			 
			raise "Failed to upload test file: #{upload_response.body}" unless upload_response.is_a?(Net::HTTPSuccess)
			 
			parsed_upload = JSON.parse(upload_response.body) rescue {}
			loader_id = parsed_upload.dig("data", "id") || parsed_upload["loaderId"] || nil
			namespace = "#{association.name.parameterize}-#{association.id}"
			  

			template_file = Rails.root.join("public", "template.json")
			template = JSON.parse(File.read(template_file))
			 
			template["nodes"][1]["data"]["inputs"]["agentModelConfig"]["FLOWISE_CREDENTIAL_ID"] = "24041b2d-1e7d-415f-9eb3-5823926c5497"
			    template["nodes"][1]["data"]["inputs"]["agentKnowledgeDocumentStores"].map! do |store|
			      store["documentStore"] = "#{document_store_id}:#{association.name.parameterize}_#{association.id}"
			      store["docStoreDescription"] = "Agent Flow"
			      store
			    end
			    template["nodes"][1]["data"]["inputs"]["agentMessages"][0]["content"] = <<~PROMPT
			      You are a helpful and polite AI Support Agent, designed to work alongside human agents. Your goal is to analyze the provided conversation history and respond only to the final User Message. Reply in a very concise and simple language.
			 
			      Follow these rules:
			 
			      Analyze Context: Review the full conversation, paying close attention to any Human Agent Message. A human's answer is the ground truth.
			 
			      Handle Handoffs:
			 
			      IF a Human Agent has just answered the query and the final User Message is an acknowledgment (e.g., "Thank you," "Okay"), provide a brief closing. Do not re-answer.
			 
			      Example closing: "You're welcome! Is there anything else I can help you with?"
			 
			      Answer New Questions:
			 
			      IF the final User Message asks a new question, search your knowledge base for the answer.
			 
			      Your answers must come exclusively from the provided files. Never invent information or use external knowledge.
			 
			      If the information is not in the files, you must state it. Respond with: "I could not find any information on that topic."
			    PROMPT
			 
			 
			# 4. Create Flowise Agent Flow
			 
			flow_payload = {
			  name: "#{association.name.parameterize}_#{association.id}",
			  description: "Agent Flow",
			  type: "AGENTFLOW",
			  deployed: true,
			  flowData: {
			    nodes: template["nodes"],
			    edges: template["edges"],
			    viewport: { x: 0, y: 0, zoom: 1 }
			  }.to_json
			}
			 
			 
			uri = URI("#{ENV['FLOWISE_SERVER_URL']}/api/v1/chatflows")
			http = Net::HTTP.new(uri.host, uri.port)
			 
			request = Net::HTTP::Post.new(uri.path, {
			  "Authorization" => "Bearer #{ENV['FLOWISE_KEY']}",
			  "Content-Type" => "application/json"
			})
			request.body = flow_payload.to_json
			flow_response = http.request(request)
			 
			flow_id = JSON.parse(flow_response.body)["id"]
			# --------------------------
	    # 6. Save to local DB
	    # --------------------------
			AgentFlow.create(
			  name: "#{association&.name&.parameterize}_#{association.id}",
			  user_id: association.property_manager_id,
			  description: "Agent Flow",
			  flow_id: flow_id
			)

			association.update(flowise_document_store_id: document_store_id, flow_id: flow_id)
		rescue StandardError => e
  		Rails.logger.info "\e[31m ******* #{e.message} ******* \e[0m"
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
