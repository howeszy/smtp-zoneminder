# frozen_string_literal: true

require 'midi-smtp-server'

class SmtpServer < MidiSmtpServer::Smtpd  
  def on_message_data_event(ctx)
    logger.debug("mail reveived at: [#{ctx[:server][:local_ip]}:#{ctx[:server][:local_port]}] from: [#{ctx[:envelope][:from]}] for recipient(s): [#{ctx[:envelope][:to]}]...")

    logger.debug(ctx[:message][:data])
  end

  def on_logging_event(ctx, severity, message, err: nil) # rubocop:disable Lint/UnusedMethodArgument
    levels = %i[debug info warn error fatal unknown]
    @custom_logger ||= ActiveSupport::TaggedLogging.new(Logger.new($stdout))
    @custom_logger.send(levels[severity], message)
  end
end

server = SmtpServer.new

flag_status_ctrl_c_pressed = false

trap('INT') do
  flag_status_ctrl_c_pressed = true
  exit 0 # rubocop:disable Rails/Exit
end

server.logger.info('Starting SMTP Server service')

at_exit do
  if server
    server.logger.info('Stopping SMTP Server service')
    server.stop
  end
  server.logger.info('MySmtpd down!')
end

server.start
server.join
