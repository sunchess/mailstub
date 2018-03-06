defmodule MailToJson.SmtpServer do

  def start_link do
    session_options = [ callbackoptions: [parse: true], allow_bare_newlines: :fix]
    smtp_port = MailToJson.config(:smtp_port)
    :gen_smtp_server.start(MailToJson.SmtpHandler, [[port: smtp_port, sessionoptions: session_options]])
  end

end
