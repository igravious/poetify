/* SimpleTreeMenu */

/* do not show arrow-head if no leaves */

(function($) {

	/* add on/off switch to enable or disable Nodeless mode? */

	var methods = {
		
		init: function() {
	    	return this.each(function() {
	    		var $this = $(this);
				if ($this.hasClass("simpleTreeMenu") === false) {
					$this.hide();
					$(this).addClass("simpleTreeMenu");
					$this.children("li").each(function() {
						methods.buildNode($(this));
					});	
					$(this).show();	
				}
	    	});		
		},
		
		buildNode: function($li) {
			if ($li.children("ul").length > 0) {
				$li.children("ul").hide();

				var $how_many = 0;
				$li.children("ul").children("li").each(function() {
					$how_many += 1;
					methods.buildNode($(this));
				});
				
					if ($how_many > 0) {
						$li.addClass("Node").click(function(event) {
							var $t = $(this);
							if ($t.hasClass("expanded")) {
								$t.removeClass("expanded");
								$t.children("ul").hide();
							} else {
								$t.addClass("expanded");
								$t.children("ul").show();
							}
							event.stopPropagation();
						});
					} else {
						$li.addClass("Nodeless").click(function(event) {
							event.stopPropagation();
						});
					}
					
			} else {
				$li.addClass("Leaf").click(function(event) {
					event.stopPropagation();
				});
				return;
			}		
		},
		
		/* helpers */
		
		expandToNode: function($li) {
			if ($li.parent().hasClass("simpleTreeMenu")) {
				if (!$li.hasClass("expanded")) {
					$li.addClass("expanded");
					$li.children("ul").show();
				}
			}
			$li.parents("li", "ul.simpleTreeMenu").each(function() {
				var $t = jQuery(this);
				if (!$t.hasClass("expanded")) {
					$t.addClass("expanded");
					$t.children("ul").show();
				}
			});
		},
		
		expandAll: function() {
			jQuery(this).find("li.Node").each(function() {
				$t = jQuery(this);
				if (!$t.hasClass("expanded")) {
					$t.addClass("expanded");
					$t.children("ul").show();
				}
			});	
		},
		
		closeAll: function() {
			jQuery("ul", jQuery(this)).hide();
			var $li = jQuery("li.Node");
			if ($li.hasClass("expanded")) {
				$li.removeClass("expanded");
			}
		}		
		
	};
	
	/* kick start */
	
	$.fn.simpleTreeMenu = function(method) {
	    if (methods[method]) {
			return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
	    } else if (typeof method === 'object' || !method) {
			return methods.init.apply(this, arguments);
	    } else {
			$.error('Method ' +  method + ' does not exist on jQuery.simpleTreeMenu');
	    }    	
	};
	
})(jQuery);