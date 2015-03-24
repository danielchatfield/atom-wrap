{CompositeDisposable, Point, Range} = require 'atom'

module.exports =
class WrapEditorView
  @content: ->
    @div class: 'wrap-wrapper'

  constructor: (@editor) ->
    @disposables = new CompositeDisposable

    @disposables.add @editor.onDidChangeGrammar =>
      @subscribeToBuffer()

    @disposables.add atom.config.onDidChange 'wrap.grammars', =>
      @subscribeToBuffer()

    @disposables.add atom.config.onDidChange 'editor.fontSize', =>
      @subscribeToBuffer()

    @subscribeToBuffer()

    @disposables.add @editor.onDidDestroy(@destroy.bind(this))

  destroy: ->
    @unsubscribeFromBuffer()
    @disposables.dispose()

  subscribeToBuffer: ->
    @unsubscribeFromBuffer()
    @preferredLineLength = atom.config.get('editor.preferredLineLength',
      scope: @editor.getRootScopeDescriptor())

    if @wrapCurrentGrammar()
      @buffer = @editor.getBuffer()
      @bufferDisposable = @buffer.onDidChange(@updateWrap.bind(this))

  unsubscribeFromBuffer: ->
    if @bufferDisposable?
      @bufferDisposable.dispose()

  wrapCurrentGrammar : ->
    grammar = @editor.getGrammar().scopeName
    grammar in atom.config.get('wrap.grammars')

  updateWrap: (event) ->

    if @lock

      # Check if the new range has gone over the edge
      if @overflowing(event.newRange)
        console.log event
        @wrapFromRange(event.newRange)
      @unlock

  wrapFromRange: (range) ->
    if @shouldWrapRange(range)
      text = @buffer.lineForRow(range.end.row)


      # Work back from col 80 until find space
      for i in [@preferredLineLength..0]
        if text[i] == ' '
          text = text.substr(0, i) + '\n' + text.substr(i+1, text.length)
          row = range.end.row
          range = new Range([row, 0], [row, range.end.column])
          @buffer.setTextInRange(range, text)
          break

  getSections: (range) ->
    # Given a range from an event returns an array of "sections". Sections can
    # be thought of as logical groups of lines in terms of wrapping. e.g a
    # paragraph of text.
    return []

  shouldWrapSection: (section) ->
    return true

  shouldWrapRange: (range) ->
    # Some ranges should not be wrapped
    return true

  overflowing: (range) ->
    return range.end.column > @preferredLineLength


  insertNewline: (position) ->
    @buffer.insert(position, '\n', undo: 'skip')

  lock: ->
    if @locked != true
      @locked = true
      return true
    return false

  unlock: ->
    @locked = false
