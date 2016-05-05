# Description:
#   chat with your hubot via Docomo Zatsudan-Taiwa(雑談対話) API
#
# Commands:
#   hubot * (it works only if it doesn't match other commands)
#
# Author:
#   - toshimaru

Docomochatter = require('docomochatter')

module.exports = (robot) ->
  client = new Docomochatter(process.env.HUBOT_DOCOMO_API_KEY)
  robot.brain.data.chat_context = {}

  is_defined_cmd = (msg) ->
    cmds = [] # list of available hubot commands
    for help in robot.helpCommands()
      splitted = help.split(' ')
      if splitted[0] is #{robot.name}
        cmd = splitted[1]
      else
        cmd = splitted[0]
      cmds.push(cmd) if cmds.indexOf(cmd) == -1
    cmd = msg.match[1].split(' ')[0]
    cmds.indexOf(cmd) != -1

  get_context = (context_id) ->
    context = {}
    if ctx = robot.brain.data.chat_context[context_id]
      context.context = ctx.context
      context.mode = ctx.mode
    context

  set_context = (context_id, res) ->
    robot.brain.data.chat_context[context_id] =
      context: res.context
      mode: res.mode

  send_message = (msg) ->
    #return if is_defined_cmd(msg)
    msg.send "No API key found for hubot-docomochatter" unless process.env.HUBOT_DOCOMO_API_KEY?

    context_id = msg.message.room
    option = get_context(context_id)
    if process.env.HUBOT_DOCOMO_CHARACTER is "WEST"
      option.t = 20
    else if process.env.HUBOT_DOCOMO_CHARACTER is "BABY"
      option.t = 30

    client.create_dialogue(msg.match[1], option)
      .then (response) ->
        set_context(context_id, response)
        msg.send(response.utt)
      .catch (error) ->
        msg.send(error)

  if process.env.HUBOT_DOCOMO_IS_RESPOND?
    robot.respond /\s(\S+)/, send_message
  else
    robot.hear /(.+)/, send_message
