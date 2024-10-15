# frozen_string_literal: true

class GptClient
  SUMMARY_PROMPT = <<~PROMPT
    Напиши заголовок "Переказ бесіди за сьогодні".
    Напиши короткий переказ бесіди за сьогодні. Роби короткі висновки по кожному учаснику бесіди.
    Стиль переказу: неформальный.
    Формат віхдних даних: "Ім'я користувача: повідомлення".
    Форматування виводу: HTML без тегів html, body, br, blockquote. Заміни теги h1, h2, h3 на b, i, u відповідно. Допустимі теги: b, i, u, a, code, pre.
    Якщо повідомлення пусті, напиши "😥 У мене немає інформації за сегодня".
  PROMPT

  CONTEXT_PROMPT = <<~PROMPT
    Далі буде наведений контекст бесіди за сьогодні
    Формат віхдних даних: "Ім'я користувача: повідомлення".
    Форматування виводу: HTML без тегів html, body, br, blockquote. Заміни теги h1, h2, h3 на b, i, u відповідно. Допустимі теги: b, i, u, a, code, pre.
    Якщо далі не буде описаного раніше формату, дай відповідь без урахування контексту.
  PROMPT

  attr_reader :client

  def initialize
    @client = OpenAI::Client.new
  end

  def get_summary_response(text)
    response = client.chat(parameters: {
                             model: 'gpt-4o-mini',
                             messages: [
                               { role: 'user', content: SUMMARY_PROMPT },
                               { role: 'user', content: text }
                             ]
                           })

    response.dig('choices', 0, 'message', 'content')
  end

  def get_prompt_response(context, prompt)
    response = client.chat(parameters: {
                             model: 'gpt-4o-mini',
                             messages: [
                               { role: 'user', content: CONTEXT_PROMPT },
                               { role: 'user', content: context },
                               { role: 'user', content: prompt }
                             ]
                           })

    response.dig('choices', 0, 'message', 'content')
  end
end
