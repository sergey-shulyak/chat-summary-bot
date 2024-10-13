require_relative './db'
require_relative '../models/message'

class Bot < Telegram::Bot::Client
  def initialize(token, hash = {})
    @db = hash.delete(:db)
    super(token, hash)
  end

  def start
    listen do |message|
      next unless message.is_a?(Telegram::Bot::Types::Message)

      handle_message(message)
    end
  end

  private

  def error_chat_id
    ENV.fetch('ERROR_CHAT_ID')
  end

  def handle_message(message)
    case message.text
    when %r{/start}
      api.send_message(chat_id: message.chat.id, text: "Привет, #{message.from.first_name}")
    when %r{/stop}
      api.send_message(chat_id: message.chat.id, text: "Ня пока, #{message.from.first_name}")
    when %r{/ping}
      api.send_message(chat_id: message.chat.id, text: '🫡')
    when %r{/summary}
      send_summary(message.chat.id)
    when %r{/cleanup}
      clean_chat_history!(message.chat.id)
    else
      save_message(message)
    end
  rescue StandardError => e
    api.send_message(chat_id: message.chat.id, text: 'Беды с башкой, извините')
    api.send_message(chat_id: error_chat_id, text: "```Ошибка: #{e.message} #{e.backtrace.join("\n\t")}```",
                     parse_mode: 'Markdown')
  end

  def gpt_client
    @gpt_client ||= GptClient.new
  end

  def send_summary(chat_id)
    api.sendChatAction(chat_id:, action: 'typing')

    if Message.messages_for_chat_empty?(db: @db.client, chat_id:)
      api.send_message(chat_id:, text: '😥 У меня нет информации о беседе за сегодня')
      return
    end

    messages = Message.messages_today(db: @db.client, chat_id:).reduce('') do |acc, message|
      "#{acc}#{message['user']}: #{message['message']}\n"
    end

    summary = gpt_client.get_summary_response(messages)

    api.send_message(chat_id:, text: summary, parse_mode: 'HTML')
  end

  def clean_chat_history!(chat_id)
    api.sendChatAction(chat_id:, action: 'typing')
    @db.cleanup!(chat_id)
    api.send_message(chat_id:, text: 'База сообщений очищена')
  end

  def save_message(message)
    Message.new(
      user: message.from.first_name,
      message: message.text,
      date: message.date,
      chat_id: message.chat.id,
      db: @db.client
    ).save!
  end
end
