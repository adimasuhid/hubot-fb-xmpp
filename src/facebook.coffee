{Adapter, Robot, EnterMessage, LeaveMessage} = require 'hubot'

FacebookApi = require 'facebook-api'
FacebookChat = require 'facebook-chat'

accessToken = process.env.HUBOT_FACEBOOK_ACCESS_TOKEN
appId = process.env.HUBOT_FACEBOOK_APP_ID
facebookId = process.env.HUBOT_FACEBOOK_USER_ID

class FacebookBot extends Adapter
  send: (envelope, messages...) ->
    for msg in messages
      console.log "Sending to #{envelope.room}: #{msg}"

      @client.send envelope.user.jid, msg

      #@user_conversation(@profile.id, msg)

  reply: (envelope, messages...) ->
    for msg in messages
      if msg.attrs? #Xmpp.Element
        @send envelope, msg
      else
        @send envelope, "#{envelope.user.name}: #{msg}"

  run: ->
    @client = new FacebookChat
      facebookId: facebookId,
      appId : appId,
      accessToken : accessToken

    @client.on 'online', @.onOnline
    #@client.on 'error', @.onError
    #@client.on 'presence', @.onPresence
    #@client.on 'roster', @.onRoster
    #@client.on 'message', @.onMessage
    #@client.on 'composing', @.onComposing
    #@client.on 'vcard', @.onVcard

  onOnline: () ->
    console.log "online"

    #Get friend list
    self.client.roster()

    #Get a vcard
    self.client.vcard()

    fbapi = FacebookApi.user(access_token)

    fbapi.me.info (err, data) ->
      if err
        console.log "Error: " + JSON.stringify(err)
      else
        console.log "Data: " + JSON.stringify(data)
        self.profile = data
        self.robot.name = data.first_name

    #Get a friend vcard
    #self.client.vcard('-FACEBOOK_ID@chat.facebook.com');

    self.emit "connected"

    #@options = options

    #@robot.brain.on 'loaded', () ->
      #self.flags.data_loaded = true

    console.log "+++"

exports.use = (robot) ->
  new FacebookBot robot

