$.ajaxSetup({
  'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
});

jQuery(document).ready(function() {
   $('table.datatable img.filter_toggle').click(function() {
       $(this).closest('table.datatable').find('tr.filter').toggle();
       $(this).closest('table.datatable').find('tr.filter_notify').toggle();
       return false;
   });
});