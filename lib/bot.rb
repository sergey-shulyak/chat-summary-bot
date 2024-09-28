require_relative '../models/message'

class Bot < Telegram::Bot::Client
  def initialize(token, hash = {})
    @db = hash.delete(:db)
    super(token, hash)
  end

  def start
    listen do |message|
      next unless message.is_a?(Telegram::Bot::Types::Message)

      case message.text
      when '/start'
        api.send_message(chat_id: message.chat.id, text: "Привет, #{message.from.first_name}")
      when '/summary'
        messages = Message.messages_today(@db).reduce('') do |acc, message|
          "#{acc}#{message['user']}: #{message['message']}\n"
        end

        summary = fetch_summary(messages)

        api.send_message(chat_id: message.chat.id, text: summary, parse_mode: 'Markdown')
      when '/stop'
        api.send_message(chat_id: message.chat.id, text: "Ня пока, #{message.from.first_name}")
      when '/cleanup'
        api.send_message(chat_id: message.chat.id, text: 'Очищаю базу сообщений...')
        Message.cleanup(@db)
        api.send_message(chat_id: message.chat.id, text: 'База сообщений очищена')
      else
        Message.new(message.from.first_name, message.text, message.date, db: @db).save!
      end
    end
  end

  private

  def fetch_summary(text)
    gpt_client.get_summary_response(text)
  end

  def gpt_client
    @gpt_client ||= GptClient.new
  end
end
