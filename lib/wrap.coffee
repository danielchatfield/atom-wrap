#
# * wrap
# * https://github.com/danielchatfield/wrap
# *
# * Copyright (c) 2015 danielchatfield
# * Licensed under the MIT license.
#
WrapEditorView = null
views = []

module.exports =
  config:
    grammars:
      type: 'array'
      default: [
        'source.asciidoc'
        'source.gfm'
        'text.git-commit'
        'text.plain'
        'text.plain.null-grammar'
      ]
  activate: (state) ->
    @disposable = atom.workspace.observeTextEditors(@addViewToEditor)

  deactivate: ->
    @disposable.dispose()

    while view = views.shift()
      view.destroy()

  addViewToEditor: (editor) ->
    WrapEditorView ?= require './wrap-editor-view'
    views.push new WrapEditorView(editor)
