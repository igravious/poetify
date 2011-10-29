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
						methods.buildNode($(this)); // how can this even work?
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
					// ah, cuz this is now different cuz of the each? (i hope)
					// More importantly, the callback is fired in the context of the current DOM element,
					// so the keyword this refers to the element. insanity averted
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
		
		/* maintaining state */
		
		arrayify: function() {
			state = [];
			$('.Node, .Leaf', $(this)).each(function(index) {
				state[index] = $(this).hasClass("expanded");
			});
			console.log(state);
			return state;
		},
	
		fromArray: function(state) {
			$('.Node, .Leaf', $(this)).each(function(index) {
				if (eval(state[index])) {
					$(this).addClass("expanded").children("ul").show();
				}
			});
		},
		
		toLocalStorage: function(state) {
			if (private.hasLocalStorage() === true) {
				localStorage.setItem(private.localStorageKey.apply(this), state.join()); // does it default to , ?
			}
		},
		
		fromLocalStorage: function() {
			if (private.hasLocalStorage() === true) {
				state = localStorage.getItem(private.localStorageKey.apply(this))
				if (state != null) {
					state = state.split(",");
					if (state.length > 0) {
						return state;
					}
				}
			}
			return null;
		},
		
		toCookieJar: function(state) {
			private.createCookie(private.localStorageKeyPrefix, JSON.stringify(state), 1);
		},
		
		fromCookieJar: function() {
			return eval('(' + private.readCookie(private.localStorageKeyPrefix) + ')');
		},
		
		serialize: function(storage) {
			state = methods.arrayify.apply(this);
			if (storage === "cookie")
				methods.toCookieJar.call(this, state);
			else if (storage === "html5")
				methods.toLocalStorage.call(this, state);
		},

		deserialize: function(storage) {
			if (storage === "cookie")
				state = methods.fromCookieJar.apply(this);
			else if (storage === "html5")
				state = methods.fromLocalStorage.apply(this);
			if (state != null ) methods.fromArray.call(this, state);
		},
		
		/* opening and closing operations */
		
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
	
	var private = {
		
		localStorageKeyPrefix: "jQuery-simpleTreeMenu-treeState-",
		
		hasLocalStorage: function() {
			if (localStorage && localStorage.setItem && localStorage.getItem) {
				return true;
			}
			else {
				return false;
			}
		},
				
		localStorageKey: function() {
			return private.localStorageKeyPrefix + $(this).attr("id");
		},
		
		createCookie: function(name,value,days) {
			if (days) {
				var date = new Date();
				date.setTime(date.getTime()+(days*24*60*60*1000));
				var expires = "; expires="+date.toGMTString();
			}
			else var expires = "";
			document.cookie = name+"="+value+expires+"; path=/";
		},
		
		readCookie: function(name) {
			var nameEQ = name + "=";
			var ca = document.cookie.split(';');
			for(var i=0;i < ca.length;i++) {
				var c = ca[i];
				while (c.charAt(0)==' ') c = c.substring(1,c.length);
				if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
			}
			return null;
		},
		
		eraseCookie: function(name) {
			createCookie(name,"",-1);
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