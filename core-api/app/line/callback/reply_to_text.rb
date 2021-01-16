require 'line/bot'

require_relative 'reply'

module Line
  module Callback
    class ReplyToText < Reply
      def reply(event)
        case event.type
        when Line::Bot::Event::MessageType::Text
          $reply_type = 'text'
          msg = event.message['text']

          user_id = get_user_id(event)
          user_name = get_user_name(user_id)

          reply_text = mk_reply_text(msg, user_id, user_name)
          monitor(
            msg: msg,
            reply_text: reply_text,
            user_id: user_id,
            user_name: user_name,
            group: get_group(event)
          )

          return mk_reply_body(reply_text)
        end
      end

      def mk_reply_text(*msg_data)
        reply_text = ''

        $ANS_OBJS.each do |obj|
          ans = obj.answer(*msg_data)
          unless ans.nil?
            reply_text = ans[0, 2000]
            break
          end
        rescue => e
          e.message
          reply_text = "エラーおつｗｗｗｗｗｗ\n\n> #{e}"
          @logger.error(e.backtrace)
          break
        end

        return reply_text
      end

      def mk_reply_body(reply_text)
        case $reply_type
        when 'text'
          return {
            type: 'text',
            text: reply_text
          }
        when 'image'
          return {
            type: 'image',
            originalContentUrl: reply_text,
            previewImageUrl: reply_text
          }
        else
          return nil
        end
      end
    end
  end
end
