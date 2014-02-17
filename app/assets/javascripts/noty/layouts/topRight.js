;(function($) {

	$.noty.layouts.topRight = {
		name: 'topRight',
		options: { // overrides options
		},
		container: {
			object: '<ul id="noty_topRight_layout_container" />',
			selector: 'ul#noty_topRight_layout_container',
			style: function() {
				$(this).css({
					top: 80,
					right: 80,
					position: 'fixed',
					width: '300px',
					height: '6px',
					margin: 0,
					padding: 0,
					listStyleType: 'none',
					zIndex: 10000000
				});

				if (window.innerWidth < 600) {
					$(this).css({
						right: 5
					});
				}
			}
		},
		parent: {
			object: '<li />',
			selector: 'li',
			css: {
				height: 60,
				"margin-bottom": 10,
			}
		},
		css: {
			display: 'none',
			width: '310px'
		},
		addClass: ''
	};

})(jQuery);