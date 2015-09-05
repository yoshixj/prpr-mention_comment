module Prpr
  module Action
    module MentionComment
      class Mention < Base
        def call
          Publisher::Adapter::Base.broadcast message
        end

        private

        def message
          Prpr::Publisher::Message.new(body: body, from: from, room: room)
        end

        def body
          event.comment.body.gsub(/@[a-zA-Z0-9_]+/) { |old|
            members[old] || old
          }
        end

        def from
          event.sender
        end

        def room
          env[:mention_comment_room]
        end

        def members
          @members ||= config.read(name).lines.map { |line|
            if line =~ / \* (\S+):\s*(\S+)/
              [$1, $2]
            end
          }.to_h
        end

        def config
          @config ||= Config::Github.new(repository_name)
        end

        def env
          Config::Env.default
        end

        def name
          env[:mention_comment_members] || 'MEMBERS.md'
        end

        def repository_name
          event.repository.full_name
        end
      end
    end
  end
end
