
$(function () {
  
    $('[data-toggle="tooltip"]').not('[data-tooltipd]').attr('data-tooltipd', true).tooltip({
      html: true,
      title: function () {
        if ($(this).attr('title').length > 0)
          return $(this).attr('title')
        else
          return $(this).next('span').html()
      }
    })  

  $(document).on('click', 'a.popup', function (e) {
    window.open(this.href, null, 'scrollbars=yes,width=600,height=600,left=150,top=150').focus();
    return false;
  });


  if ($(window).width() < 768) {
    $('.alternative').click(function () {
      $('.alternative a.site').css('display', 'none')
      $('.alternative a.discuss').css('display', 'none')
      $('a.site', this).css('display', 'block')
      $('a.discuss', this).show()
    })
    $('.alternative a.site').append('<div style="text-decoration: underline" class="mt-3">View site</div>')
  } else {
    $('.alternative').hover(
            function () {
              $('a.site', this).css('display', 'block')
              $('a.discuss', this).show()
            },
            function () {
              $('a.site', this).css('display', 'none')
              $('a.discuss', this).hide()
            })
  }


});