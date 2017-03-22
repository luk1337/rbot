# -*- coding: utf-8 -*-
#
# :title: Sed plugin
#
# Author:: MelmothX <melmothx@gmail.com>
# Copyright:: No copyright
# License:: Public Domain
#

class Sed < Plugin
  def initialize
    super

    # create the multidimensional hash
    @amendlog = Hash.new
  end

  def help(plugin, topic="")
    "Fix the previous sentence using regexp and a sed-like syntax. Supported delimiters are /|,! and the modifier \"g\". Grouping is supported via parens, and backreferencing is done via \\1 \\2 and so on. You don't have to directly address the bot. Examples: <nick>hello <nick>s/e/u/"
  end

  def message(m)
    return unless m.public?

    # log
    source = m.source
    channel = m.channel
    message = m.message

    unless @amendlog.has_key?(channel)
      @amendlog[channel] = Hash.new
    end

    unless @amendlog[channel].key?(source)
      @amendlog[channel][source] = []
    end

    if m.message.match(/^s([\/|,!])(.*?)\1(.*?)\1(g?)/)
      target = Regexp.new($2)
      replace_with = $3
      global = $4

      @amendlog[channel][source].reverse.each { |currentMessage|
        if global == ""
          newstring = currentMessage.sub(target, replace_with)
        else
          newstring = currentMessage.gsub(target, replace_with)
        end

        if newstring != currentMessage
          m.reply("#{source} #{_("meant")}: \"#{newstring}\"", :nick => false)

          @amendlog[channel][source].clear

          return
        end
      }

      failreply = _("You did something wrong... Try s/you/me/ or tell me \"help sed\"")
      m.reply("#{source}: #{failreply}")

      return
    end

    if @amendlog[channel][source].length >= 5
      @amendlog[channel][source].shift
    end

    @amendlog[channel][source].push(message)
  end
end
plugin = Sed.new
