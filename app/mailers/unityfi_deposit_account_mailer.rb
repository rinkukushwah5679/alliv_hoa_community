class UnityfiDepositAccountMailer < ApplicationMailer
  def unity_deposit_form(deposit_account)
    @deposit_account = deposit_account

    attach_file(@deposit_account.signers_drivers_license)
    attach_file(@deposit_account.voided_check_bank_latter_bank_signature_card)
    attach_file(@deposit_account.ssn_or_ein_latter)
    attach_file(@deposit_account.article_organization_incorporation)
    attach_file(@deposit_account.additional_signer_drivers_license)

    template_path = Rails.root.join(
      "app", "views", "unityfi_deposit_account_mailer", "unity_deposit_form.html.erb"
    )
    erb_template = File.read(template_path)
    html_body = ERB.new(erb_template).result(binding)
    # plain_text = ActionView::Base.full_sanitizer.sanitize(html_body)
    # Notification.create(user_id: @user.id, notifiable: announcement, title: subject, message: plain_text, delivery_methods: ["email", "portal"], created_by: announcement.user_id, updated_by: announcement.user_id)
    mail(
      to: "Underwriting@unityfisolutions.com",
      subject: "Alliv – New HOA / Management Company",
    ) do |format|
      format.html { render html: html_body.html_safe }
    end

    # mail(
    #   to: "rinkukushwah679@gmail.com",
    #   subject: "New HOA / Management Company"
    # )
  end

  private

  def attach_file(file)
    return unless file.attached?

    attachments[file.filename.to_s] = {
      mime_type: file.content_type,
      content: file.download
    }
  end
end
