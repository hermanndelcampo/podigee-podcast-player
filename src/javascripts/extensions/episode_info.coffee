$ = require('jquery')
sightglass = require('sightglass')
rivets = require('rivets')

class EpisodeInfo
  @extension:
    name: 'EpisodeInfo'
    type: 'panel'

  constructor: (@app) ->
    @episode = @app.episode
    return unless @episode

    return unless @episode.description

    @renderPanel()
    @renderButton()

    @app.renderPanel(this)

  renderButton: =>
    @button = $(@buttonHtml)
    @button.on 'click', =>
      @app.togglePanel(@panel)

  renderPanel: =>
    @panel = $(@panelHtml)
    rivets.bind(@panel, @episode)
    @panel.hide()

  buttonHtml:
    """
    <button class="fa fa-info episode-info-button" title="Show more info"></button>
    """

  panelHtml:
    """
    <div class="episode-info">
      <h1 class="episode-title">{ title }</h1>
      <p class="episode-subtitle">{ subtitle }</p>
      <p class="episode-description">{ description }</p>
    </div>
    """

module.exports = EpisodeInfo
