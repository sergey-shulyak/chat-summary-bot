# frozen_string_literal: true

require_relative '../config/openai'

class GptClient
  PROMPT = 'Напиши краткий пересказ сообщений каждого пользователя группового чата и напиши краткий вывод беседы в разговорном стиле.'

  attr_reader :client

  def initialize
    @client = OpenAI::Client.new
  end

  def get_summary_response(text)
    response = client.chat(parameters: {
                             model: 'gpt-4o-mini',
                             messages: [
                               { role: 'user', content: PROMPT },
                               { role: 'user', content: text }
                             ]
                           })

    text_response = response.dig('choices', 0, 'message', 'content')
    puts text_response
    text_response
  end
end
