App.InvestmentTags =

  initialize: ->
    $tag_input = $('input.js-tag-list')

    $('body .js-add-investment-tag-link').each ->
      $this = $(this)

      unless $this.data('initialized') is 'yes'
        $this.on('click', ->
          name = $(this).text()
          current_tags = $tag_input.val().split(',').filter(Boolean)

          if $.inArray(name, current_tags) >= 0
            current_tags.splice($.inArray(name, current_tags), 1)
          else if current_tags.length == 0
            current_tags.push name
          else
            current_tags = [name]

          $tag_input.val(current_tags.join(','))
          false
        ).data 'initialized', 'yes'
