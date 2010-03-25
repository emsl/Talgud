$.ajaxSetup({
  'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
});

function initFormHints() {
    var bubble = document.createElement('div');
    $(bubble).attr('class', 'bubble').html('<div class="bubble-arrow"></div><div class="bubble-inner"></div>');
    
    displayHint = function(list_item) {
      var hint = $(list_item).find('p.inline-hints')
      if (hint.length > 0) {
          $(bubble).find('.bubble-inner').html($(hint[0]).html());
          list_item.append($(bubble));
      }
    }
    
    $('form.formtastic fieldset li input, form.formtastic fieldset li select, form.formtastic fieldset li textarea').focus(function() {
      displayHint($(this).parent('li'));
    });
}
