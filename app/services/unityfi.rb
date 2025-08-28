require "uri"
require "json"
require "net/http"

class Unityfi

	def generate_token

		unityfi = UnityfiAuthenticate.last
		return unityfi if unityfi.present? && unityfi&.token.present? && Time.now < unityfi.token_expires_at

		url = URI("#{ENV['UNITYFI_BASE_URL']}/authentication")

		https = Net::HTTP.new(url.host, url.port)
		https.use_ssl = true

		request = Net::HTTP::Post.new(url)
		request["Content-Type"] = "application/json"
		request.body = JSON.dump({
		  "APIKey": ENV['UNITYFI_API_KEY'],
		  "Password": ENV['UNITYFI_PASSWORD']
		})

		response = https.request(request)
		if response.code == "200"
			data = JSON.parse(response.body)
			if unityfi.present?
        # update existing record
        unityfi.update(
          token: data["AuthenticationToken"],
          token_expires_at: Time.now + 1.hour
        )
      else
        # create new record
        unityfi = UnityfiAuthenticate.create(
          token: data["AuthenticationToken"],
          company_id: data["CompanyId"],
          token_expires_at: Time.now + 1.hour
        )
      end
		end
		unityfi
	end

	# Create Location User (User Or Association)
	def create_location_user(assocation)
		user = assocation.user
		unityfi = generate_token
		url = URI("#{ENV['UNITYFI_BASE_URL']}/locationuser")

		https = Net::HTTP.new(url.host, url.port)
		https.use_ssl = true

		request = Net::HTTP::Post.new(url)
		request["Content-Type"] = "application/json"
		request["X-Authentication-Token"] = "#{unityfi.token}"
		request.body = {
			"Active" => true,
			"Country" => "US", #Required
			"Email" => user.email,
			"FirstName" => user.first_name,
			"LastName" => user.last_name,
			"LocationID" => 58122
			# "City" => "Charlotte",
			# "CompanyID" => 0,
			# "Phone" => "7045555555",
			# "State" => "NC",
			# "Street1" => "123 Test Lane",
			# "Street2" => "Suite 100",
			# "TypeOfPhone" => "Mobile",
			# "Zip" => "28226"
		}.to_json

		response = https.request(request)
		if response.code == "201"
			data = JSON.parse(response.body)
			assocation.update_columns(location_user_id: data["LocationUserID"])
		end
		puts response.read_body
	end


	# Create Funding Account, Bank account
	def create_funding_account(location_user, bank)
		unityfi = generate_token
		url = URI("#{ENV['UNITYFI_BASE_URL']}/locationuser/#{location_user.location_user_id}/fundingaccount")

		https = Net::HTTP.new(url.host, url.port)
		https.use_ssl = true
		# get actual user object
		user = location_user.is_a?(Association) ? location_user.user : location_user
		request = Net::HTTP::Post.new(url)
		request["Content-Type"] = "application/json"
		request["X-Authentication-Token"] = "#{unityfi.token}"
		request.body = {
			"AccountType" => bank.bank_account_type, #Required
			"Active"=> true,
			"BankAccount" => {
				"AccountNumber" => bank.account_number,
				"IsBusinessBankAccount" => false,
				"RoutingNumber" => bank.routing_number
			},
			"CardAccount" => nil,
			"City" => "Charlotte",
			"FirstName" => user.first_name,
			"LastName" => user.last_name,
			"FundingAccountName" => bank.name,
			"State" => "NC",
			"Street1" => "123 Test Lane",
			"Zip" => "28226"
			# "CompanyID"=>0,
			# "Country" => "US",
			# "CustomerVerification"=>nil,
			# "FundingAccountId"=> nil,
			# "NameOnAccount" => user.full_name,
			# "Phone" => "7045555555",
			# "Street2" => "Suite 100"
		}.to_json

		response = https.request(request)
		data = JSON.parse(response.body)
		if response.code == "201"
			bank.update_columns(funding_account_id: data["FundingAccountId"], unityfi_bank_details_json: data.to_json, is_verified: true)
		else
			bank.update_columns(unityfi_bank_details_json: data.to_json)
		end
		puts response.read_body
	end
end