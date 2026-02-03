class MeetingEventMailer < ApplicationMailer
	def notify_admins_and_managers_when_create_meeting(user, meeting, association)
		@user = user
		@meeting = meeting
		@association = association
		subject = "New Meeting / Event Scheduled"

    @meeting.event_attachments.each do |attachment|
      attachments[attachment.filename.to_s] = {
        mime_type: attachment.content_type,
        content: attachment.download
      }
    rescue StandardError => e
      Rails.logger.info "\e[31m **********Meeting skipped: #{e.message} \e[0m"
    end
		template_path = Rails.root.join(
      "app", "views", "meeting_event_mailer", "notify_admins_and_managers_when_create_meeting.html.erb"
    )

    erb_template = File.read(template_path)
    html_body = ERB.new(erb_template).result(binding)
    plain_text = ActionView::Base.full_sanitizer.sanitize(html_body)
    Notification.create(user_id: @user.id, notifiable: meeting, title: subject, message: plain_text, delivery_methods: ["email", "portal"], created_by: meeting.created_by, updated_by: meeting.updated_by)
    mail(
      to: @user.email,
      subject: subject,
    ) do |format|
      format.html { render html: html_body.html_safe }
    end
	end
end