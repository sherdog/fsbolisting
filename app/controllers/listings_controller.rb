class ListingsController < ApplicationController

	#user listing
	def list

	end

	def index

		@cities = Listing.select(:city).uniq

		if params[:city].present? 
			@selected_city = params[:city]
		end

		if params[:state].present?
			@selected_state = params[:state]
		end

		if params[:bedrooms].present?
			@selected_bedrooms = params[:bedrooms]
		end

		if params[:bathrooms].present?
			@selected_bathrooms = params[:bathrooms]
		end

		if params[:price_from]
			@selected_price_from = params[:price_from]
		end

		if params[:price_to]
			@selected_price_to = params[:price_to]
		end

		scope = Listing

		if params[:city].present?
			scope = scope.where(["city = ?", params[:city]]).inspect
		end

		if params[:bedrooms].present?
			scope = scope.where("bedrooms >= ?", params[:bedrooms])
		end

		if params[:bathrooms].present?
			scope = scope.where("bathrooms >= ?", params[:bathrooms])
		end

		if params[:price_from].present?
			scope = scope.where("price >= ?", params[:price_from].gsub(/\,/,""))
		end

		if params[:price_to].present?
			scope = scope.where("price <= ?", params[:price_to].gsub(/\,/,""))
		end
		
		if params[:search].present?
			@listings = scope
		elsif params[:q].present?
			@listings = Listing.near(params[:q],10)
		else
			@listings = Listing.page(params[:page]).per(10)
		end
		


	end
	#Send SMS Message
	#Provided by Clockworks
	def send_by_sms
		# ActionMailer deliverya
		recipeintNumberRaw = params[:mobile_number].gsub!(/[^0-9]/,'')
		recipeintNumberFormatted = params[:mobile_number]
		@listing = Listing.find(params[:listing_id])

		sms_message = 'Click to view the listing on ' + @listing.address_1 + ' ' + @listing.address_2 + ' ' + @listing.city + ' ' + @listing.state + ' ' + listing_url(@listing)

		sms_fu = SMSFu::Client.configure(:delivery => :action_mailer)
		sms_fu.deliver(recipeintNumberRaw, params[:carrier][0] , sms_message, :from => 'alert@fsbolisting.com')
		return_response = { "status" => "ok", "number" => recipeintNumberFormatted }
		render :json => return_response.to_json, :callback => params[:callback]

	end
	#public listings
	#search variables to filter results
	def browse
		@listings = Listings.find(:all)
	end

	def view
		require 'net/http'
		require 'xml-object'
		great_schools_url = 'http://api.greatschools.org/schools/nearby?key=' + GREATSCHOOLS_API_KEY + '&state=IA&zip=50707&limit=5'


		s = Net::HTTP.get_response(URI.parse(great_schools_url)).body
	




		@schools = Hash.from_xml(s).to_json
		abort(@schools.class)
		sms_fu = SMSFu::Client.configure(:delivery => :action_mailer)
		@listing = Listing.find(params[:id])
		@sms_carriers = sms_fu.get_carriers

	end

	#public listing view
	def show
		@listing = Listing.find(params[:id])

		@user_messages = UserMessage.where(user_id: current_user.id)
		@message_count = @user_messages.count
	end

	def get_lat_long

	end

	def what_now
		@listing = Listing.find(params[:id])
	end

	def share
		@listing = Listing.find(params[:id])
		@user_messages = UserMessage.where(user_id: current_user.id)
		@message_count = @user_messages.count

	end
	#user create listing
	def create
		@listing = Listing.new(params[:listing])
		@listing.user_id = current_user.id
		#get lat/long from address

		if @listing.save
			ListingMailer.send_listing_confirm(@listing).deliver
			flash[:alert] = 'Your property was successfully added'
			#redirect_to view_listing_path(@listing)
			redirect_to what_now_listing_path(@listing)
		else
			render "new"
		end
		
		
	end


	def new
		if !user_signed_in?
			flash[:error] = "You must be signed in or have an account to submit a property"
			redirect_to new_user_session_path
		end

		@heating_choices = [ ["Gas", "Gas"], ["Electric", "Electric"], ["Geothermal", "Geothermal"], ["Other", "Other"]]
		@cooling_choices = [ ["Central Air", "Central Air"], ["Geothermal", "Geothermal"], ["None", "None"], ["Other", "Other"]]
		@property_types = [ ["Single Family", "Single Family"], ["Condo", "Condo"], ["Multi Family", "Multi Family"], ["Vacant Land", "Vacant Land"], ["Mobile Home", "Mobile Home"] ]
		@basement_types = [ ["Finished", "Finished"], ["Partially Finished", "Partially Finished"], ["Unfinished", "Unfinished"], ["Other", "Other"], ["None", "None"]]

		@bathroom_col = (1..10).step(0.25)
		@states = [
	    [ "Alabama", "AL" ],
	    [ "Alaska", "AK" ],
	    [ "Arizona", "AZ" ],
	    [ "Arkansas", "AR" ],
	    [ "California", "CA" ],
	    [ "Colorado", "CO" ],
	    [ "Connecticut", "CT" ],
	    [ "Delaware", "DE" ],
	    [ "Florida", "FL" ],
	    [ "Georgia", "GA" ],
	    [ "Hawaii", "HI" ],
	    [ "Idaho", "ID" ],
	    [ "Illinois", "IL" ],
	    [ "Indiana", "IN" ],
	    [ "Iowa", "IA" ],
	    [ "Kansas", "KS" ],
	    [ "Kentucky", "KY" ],
	    [ "Louisiana", "LA" ],
	    [ "Maine", "ME" ],
	    [ "Maryland", "MD" ],
	    [ "Massachusetts", "MA" ],
	    [ "Michigan", "MI" ],
	    [ "Minnesota", "MN" ],
	    [ "Mississippi", "MS" ],
	    [ "Missouri", "MO" ],
	    [ "Montana", "MT" ],
	    [ "Nebraska", "NE" ],
	    [ "Nevada", "NV" ],
	    [ "New Hampshire", "NH" ],
	    [ "New Jersey", "NJ" ],
	    [ "New Mexico", "NM" ],
	    [ "New York", "NY" ],
	    [ "North Carolina", "NC" ],
	    [ "North Dakota", "ND" ],
	    [ "Ohio", "OH" ],
	    [ "Oklahoma", "OK" ],
	    [ "Oregon", "OR" ],
	    [ "Pennsylvania", "PA" ],
	    [ "Rhode Island", "RI" ],
	    [ "South Carolina", "SC" ],
	    [ "South Dakota", "SD" ],
	    [ "Tennessee", "TN" ],
	    [ "Texas", "TX" ],
	    [ "Utah", "UT" ],
	    [ "Vermont", "VT" ],
	    [ "Virginia", "VA" ],
	    [ "Washington", "WA" ],
	    [ "West Virginia", "WV" ],
	    [ "Wisconsin", "WI" ],
	    [ "Wyoming", "WY" ]
	  ].freeze
	  
		@listing = Listing.new
		9.times { @listing.images.build }

		
	end
	#user updating list
	# GET
	def edit
		@heating_choices = [ ["Gas", "Gas"], ["Electric", "Electric"], ["Geothermal", "Geothermal"], ["Other", "Other"]]
		@cooling_choices = [ ["Central Air", "Central Air"], ["Geothermal", "Geothermal"], ["None", "None"], ["Other", "Other"]]
		@property_types = [ ["Single Family", "Single Family"], ["Condo", "Condo"], ["Multi Family", "Multi Family"], ["Vacant Land", "Vacant Land"], ["Mobile Home", "Mobile Home"] ]
		@basement_types = [ ["Finished", "Finished"], ["Partially Finished", "Partially Finished"], ["Unfinished", "Unfinished"], ["Other", "Other"], ["None", "None"]]

		@bathroom_col = (1..10).step(0.25)
		@states = [
	    [ "Alabama", "AL" ],
	    [ "Alaska", "AK" ],
	    [ "Arizona", "AZ" ],
	    [ "Arkansas", "AR" ],
	    [ "California", "CA" ],
	    [ "Colorado", "CO" ],
	    [ "Connecticut", "CT" ],
	    [ "Delaware", "DE" ],
	    [ "Florida", "FL" ],
	    [ "Georgia", "GA" ],
	    [ "Hawaii", "HI" ],
	    [ "Idaho", "ID" ],
	    [ "Illinois", "IL" ],
	    [ "Indiana", "IN" ],
	    [ "Iowa", "IA" ],
	    [ "Kansas", "KS" ],
	    [ "Kentucky", "KY" ],
	    [ "Louisiana", "LA" ],
	    [ "Maine", "ME" ],
	    [ "Maryland", "MD" ],
	    [ "Massachusetts", "MA" ],
	    [ "Michigan", "MI" ],
	    [ "Minnesota", "MN" ],
	    [ "Mississippi", "MS" ],
	    [ "Missouri", "MO" ],
	    [ "Montana", "MT" ],
	    [ "Nebraska", "NE" ],
	    [ "Nevada", "NV" ],
	    [ "New Hampshire", "NH" ],
	    [ "New Jersey", "NJ" ],
	    [ "New Mexico", "NM" ],
	    [ "New York", "NY" ],
	    [ "North Carolina", "NC" ],
	    [ "North Dakota", "ND" ],
	    [ "Ohio", "OH" ],
	    [ "Oklahoma", "OK" ],
	    [ "Oregon", "OR" ],
	    [ "Pennsylvania", "PA" ],
	    [ "Rhode Island", "RI" ],
	    [ "South Carolina", "SC" ],
	    [ "South Dakota", "SD" ],
	    [ "Tennessee", "TN" ],
	    [ "Texas", "TX" ],
	    [ "Utah", "UT" ],
	    [ "Vermont", "VT" ],
	    [ "Virginia", "VA" ],
	    [ "Washington", "WA" ],
	    [ "West Virginia", "WV" ],
	    [ "Wisconsin", "WI" ],
	    [ "Wyoming", "WY" ]
	  ].freeze
	   

		@listing = Listing.find(params[:id])
		9.times { @listing.images.build }
	end

	#user updated listing
	# PUT
  def update
    @listing = Listing.find(params[:id])

    respond_to do |format|
      if @listing.update_attributes(params[:listing])
        format.html { redirect_to @listing, notice: 'Your property was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @listing.errors, status: :unprocessable_entity }
      end
    end
  end

	#user deleting listing
	#POST
	def delete

	end

	private

	  def listing_params
	  		params.require(:listing).permit(:address_1, :address_2, :city, :state, :zipcode, :price, :sqft, :type, :bedrooms, :basement, :status, :bathrooms, :lotsize, :fireplace, :cooling, :garage, :heating, :year_built, :interior_fetaures, :exterior_features, :elementary_school, :middle_school, :high_school, :contact_number, :contact_email, :mls_number)
	  end		
end
