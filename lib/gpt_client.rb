# frozen_string_literal: true

class GptClient
  PROMPT = <<~PROMPT
    Напиши заголовок "Переказ бесіди за сьогодні".
    Напиши короткий переказ бесіди за сьогодні. Роби короткі висновки по кожному учаснику бесіди.
    Стиль переказу: неформальный.
    Формат віхдних даних: "Ім'я користувача: повідомлення".
    Форматування виводу: HTML без тегів html, body, br, blockquote. Заміни теги h1, h2, h3 на b, i, u відповідно. Допустимі теги: b, i, u, a, code, pre.
    Якщо повідомлення пусті, напиши "😥 У мене немає інформації за сегодня".
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
