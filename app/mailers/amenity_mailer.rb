class AmenityMailer < ApplicationMailer
	#For unit owner
	def notification_for_amenity_booking(user, amenity, association)
		@user = user
    @amenity = amenity
    @association = association

    subject = "New amenity added in your association"

    @amenity.amenity_attachments.each do |attachment|
      attachments[attachment.filename.to_s] = {
        mime_type: attachment.content_type,
        content: attachment.download
      }
    rescue StandardError => e
      Rails.logger.info "\e[31m **********Amenity skipped: #{e.message} \e[0m"
    end

    template_path = Rails.root.join(
      "app", "views", "amenity_mailer", "notification_for_amenity_booking.html.erb"
    )

    erb_template = File.read(template_path)
    html_body = ERB.new(erb_template).result(binding)
    plain_text = ActionView::Base.full_sanitizer.sanitize(html_body)
    Notification.create(user_id: @user.id, notifiable: amenity, title: subject, message: plain_text, delivery_methods: ["email", "portal"], created_by: amenity.created_by, updated_by: amenity.updated_by)
    mail(
      to: @user.email,
      subject: subject,
    ) do |format|
      format.html { render html: html_body.html_safe }
    end
	end

	#For Board Member
	def board_members_notification_for_amenity_booking(user, amenity, association)
		@user = user
    @amenity = amenity
    @association = association

    subject = "New amenity added in your association"

    @amenity.amenity_attachments.each do |attachment|
      attachments[attachment.filename.to_s] = {
        mime_type: attachment.content_type,
        content: attachment.download
      }
    rescue StandardError => e
      Rails.logger.info "\e[31m **********Amenity skipped: #{e.message} \e[0m"
    end

    template_path = Rails.root.join(
      "app", "views", "amenity_mailer", "board_members_notification_for_amenity_booking.html.erb"
    )

    erb_template = File.read(template_path)
    html_body = ERB.new(erb_template).result(binding)
    plain_text = ActionView::Base.full_sanitizer.sanitize(html_body)
    Notification.create(user_id: @user.id, notifiable: amenity, title: subject, message: plain_text, delivery_methods: ["email", "portal"], created_by: amenity.created_by, updated_by: amenity.updated_by)
    mail(
      to: @user.email,
      subject: subject,
    ) do |format|
      format.html { render html: html_body.html_safe }
    end
	end
end
