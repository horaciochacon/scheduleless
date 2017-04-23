$(document).on("turbolinks:load", function() {
  if($('#location-available-employees').length) {
    var available_employees = new Bloodhound({
      datumTokenizer: Bloodhound.tokenizers.obj.whitespace('value'),
      queryTokenizer: Bloodhound.tokenizers.whitespace,
      remote: {
        url: $("#location-available-employees").data("url"),
        wildcard: 'QUERY'
      }
    });

    $('#location-available-employees').typeahead(null, {
      hint: true,
      name: 'employees',
      display: 'email',
      limit: 10,
      source: available_employees,
      templates: {
        empty: [
          '<div class="empty-message">',
            'No employees found',
          '</div>'
        ].join('\n')
      }
    });

    $('#location-available-employees').bind('typeahead:selected', function(obj, datum, name) {
      $("#user_location_user_id").val(datum.id)
    });
  }
});
