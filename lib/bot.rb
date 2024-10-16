# frozen_string_literal: true

class Bot < Telegram::Bot::Client
  def initialize(token, named_args = {})
    @db = named_args.delete(:db)
    super(token, named_args)
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

  def gpt_client
    @gpt_client ||= GptClient.new
  end

  def chat_messages_context(chat_id)
    Message.messages_today(db: @db.client, chat_id:).reduce('') do |acc, message|
      "#{acc}#{message['user']}: #{message['message']}\n"
    end
  end

  def handle_message(message)
    case message.text
    when %r{/start}
      api.send_message(chat_id: message.chat.id, text: "Привіт, #{message.from.first_name}")
    when %r{/stop}
      api.send_message(chat_id: message.chat.id, text: "Бувай, #{message.from.first_name}")
    when %r{/ping}
      api.send_message(chat_id: message.chat.id, text: '🫡')
    when %r{/summary}
      send_summary(message.chat.id)
    when %r{/ask}
      send_prompt_reply(message.chat.id, message.text)
    when %r{/cleanup}
      clean_chat_history!(message.chat.id)
    else
      save_message(message)
    end
  rescue StandardError => e
    api.send_message(chat_id: message.chat.id, text: 'Бідося з головою, вибачайте 🥴')
    api.send_message(chat_id: error_chat_id, text: "```Помилка: #{e.message} #{e.backtrace.join("\n\t")}```",
                     parse_mode: 'Markdown')
  end

  def send_summary(chat_id)
    api.sendChatAction(chat_id:, action: 'typing')

    if Message.messages_for_chat_empty?(db: @db.client, chat_id:)
      api.send_message(chat_id:, text: '😥 У мене немає інформації за сьогодні')
      return
    end

    summary = gpt_client.get_summary_response(chat_messages_context(chat_id))
    api.send_message(chat_id:, text: summary, parse_mode: 'HTML')
  end

  def send_prompt_reply(chat_id, message)
    api.sendChatAction(chat_id:, action: 'typing')

    prompt = message.gsub(%r{/ask@group_summary_gpt_bot}, '').gsub(%r{/ask}, '').strip

    if prompt.empty?
      api.send_message(chat_id:, text: '😊 Схоже ви забули задати питання')
      return
    end

    response = gpt_client.get_prompt_response(chat_messages_context(chat_id), prompt)
    api.send_message(chat_id:, text: response, parse_mode: 'HTML')
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

  def clean_chat_history!(chat_id)
    api.sendChatAction(chat_id:, action: 'typing')
    @db.cleanup!(chat_id)
    api.send_message(chat_id:, text: 'База повідомлень для цього чату очищена')
  end
end
