module V1
	class DownloadsController < ExportDataController
		def download_file
			begin
				filename = params[:filename]
				filepath = Rails.root.join("tmp", "exports", filename)
				if File.exist?(filepath) && File.ctime(filepath) > (Time.now - 5.minutes)
					send_file filepath, type: "text/csv", disposition: "attachment", filename: filename
					# File.delete(filepath) if File.exist?(filepath)
				else
					render json: {status: 404, success: false, data: nil, message: "File not found"}, :status => :not_found
				end
			rescue StandardError => e
				render json: {status: 500, success: false, data: nil, message: e.message}, status: :internal_server_error
			end
		end
	end
end