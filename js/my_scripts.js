$(document).mouseup(function(e) {
    var container = $("#box-search-product");
	var container2 = $("#key_search");
    if (!container.is(e.target) && container.has(e.target).length === 0
	&& !container2.is(e.target) && container2.has(e.target).length === 0) {
        //$('#box-search-product').addClass('hide');
		$('#box-search-product').hide();
	}
	
	var container2 = $("#list-customer");
    if (!container2.is(e.target) && container2.has(e.target).length === 0) {
        //$('#box-search-product').addClass('hide');
		$('#list-customer').hide();
	}
});
