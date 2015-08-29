$ = require('jquery')
_ = require('lodash')
sightglass = require('sightglass')
rivets = require('rivets')

Utils = require('../utils.coffee')

class ChapterMark
  constructor: (context, callback) ->
    @context = context
    @callback = callback

  render: =>
    @elem = $(@defaultHtml)
    rivets.bind(@elem, @context)
    @elem.on('click', 'img, span', @context, @callback)

    return @elem

  defaultHtml:
    """
    <li rv-data-start="start" class="chaptermark">
      <img rv-src="image" rv-if="image" class="chaptermark-image"/>
      <span class="chaptermark-start">{ start }</span>
      <span class="chaptermark-title">{ title }</span>
      <a rv-if="href" rv-href="href" target="_blank" class="chaptermark-href"><i class="fa fa-link"></i></a>
    </li>
    """

class ChapterMarks
  @extension:
    name: 'ChapterMarks'
    type: 'panel'

  constructor: (@app) ->
    @chaptermarks = @app.episode.chaptermarks
    return unless @chaptermarks && @chaptermarks.length

    @options = _.extend(@defaultOptions, @app.extensionOptions.ChapterMarks)

    @renderPanel()
    @renderButton()
    @attachEvents()

    @app.renderPanel(this)

  defaultOptions:
    showOnStart: false

  click: (event) =>
    time = event.data.start
    @app.player.media.currentTime = Utils.hhmmssToSeconds(time)

  renderButton: =>
    @button = $(@buttonHtml)
    @button.on 'click', =>
      @app.togglePanel(@panel)

  renderPanel: =>
    @panel = $(@panelHtml)
    @panel.hide() unless @options.showOnStart
    @chaptermarks.forEach((item, index, array) =>
      item.elem = new ChapterMark(item, @click).render()

      @panel.find('ul').append(item.elem)
    )

  attachEvents: =>
    $(@app.player.media).on('timeupdate', @setActiveMark)

  setActiveMark: () =>
    time = @app.player.media.currentTime
    if time <= Utils.hhmmssToSeconds(@chaptermarks[0].start)
      @deactivateAll()
      @activateMark(@chaptermarks[0])
    else
      _(@chaptermarks).findLast (mark) =>
        markTime = Utils.hhmmssToSeconds(mark.start)
        return unless time >= markTime

        @deactivateAll()
        @activateMark(mark)

  activateMark: (mark) =>
    mark.elem.addClass('active')

  deactivateAll: =>
    @panel.find('li').removeClass('active')

  buttonHtml:
    """
    <button class="fa fa-list chaptermarks-button" title="Show chaptermarks"></button>
    """

  panelHtml:
    """
    <div class="chaptermarks">
      <h3>Chaptermarks</h3>

      <ul></ul>
    </div>
    """

module.exports = ChapterMarks
