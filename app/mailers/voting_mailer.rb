class VotingMailer < ApplicationMailer
  def vote_management_created(user, vote_management)
    @user = user
    @vote_management = vote_management
    @association = vote_management.custom_association

    # subject = "📢 New vote_management from #{@association.name}"
    subject = "📢🗳️ #{vote_management.title}"

    @vote_management.vote_management_attachments.each do |attachment|
      # next unless attachment.attached?

      # Optional size limit (10MB)
      # next if attachment.byte_size > 10.megabytes

      attachments[attachment.filename.to_s] = {
        mime_type: attachment.content_type,
        content: attachment.download
      }
    rescue StandardError => e
      Rails.logger.info "**********Voting skipped: #{e.message}"
    end

    template_path = Rails.root.join(
      "app", "views", "voting_mailer", "vote_management_created.html.erb"
    )

    erb_template = File.read(template_path)
    html_body = ERB.new(erb_template).result(binding)
    plain_text = ActionView::Base.full_sanitizer.sanitize(html_body)
    Notification.create(user_id: @user.id, notifiable: vote_management, title: subject, message: plain_text, delivery_methods: ["email", "portal"], created_by: vote_management.created_by, updated_by: vote_management.updated_by)
    mail(
      to: @user.email,
      subject: subject,
    ) do |format|
      format.html { render html: html_body.html_safe }
    end
  end
end
