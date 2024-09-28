# frozen_string_literal: true

require_relative '../config/openai'

class GptClient
  PROMPT = <<~PROMPT
    Напиши заголовок "Пересказ беседы за сегодня".
    Напиши краткий пересказ беседы за сегодня. Делай короткие выводы по каждому участнику беседы.
    Стиль пересказа: неформальный, слегка ироничный.
    Формат входных данных: "Имя пользователя: сообщение".
    Форматирование вывода: HTML без тегов html, body, br, blockquote. Замени теги h1, h2, h3 на b, i, u соответственно. Допустимые теги: b, i, u, a, code, pre.
    Если сообщения пустые, напиши "😥 У меня нет информации о беседе за сегодня".
  PROMPT

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

    response.dig('choices', 0, 'message', 'content')
  end
end
