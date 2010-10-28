/**
 * IE HTML5 elements fix - jQuery plugin
 * Copyright (c) 2010 Johan de Jong <http://johan.notitia.nl>
 *
 * Creative Commons Attribution-Share Alike 3.0
 * http://creativecommons.org/licenses/by-sa/3.0/
 *
 * How to use:
 *     - include the jQuery core as normal at the HEAD element
 *       <script type="text/javascript" src="/path/to/jquery.js"></script>
 *
 *     - include this file at the HEAD element
 *       <script type="text/javascript" src="/path/to/jquery.html5.js"></script>
 *
 *     - call the function at the HEAD element, *OUTSIDE* $(document).ready(); !!!
 *       <script type="text/javascript">
 *          $.html5();										// default usage
 *          $.html5('wrapper,content,copyright');			// with custom tags as a string, comma seperated
 *
 *          $(document).ready();							// now you can do the rest of your code
 *       </script>
 */

(function($){
	$.extend({
		html5 : function(tags){
			// only execute when used in Internet Explorer
			if($.browser.msie){
				// list of (known) HTML5 elements
				e = "abbr,article,aside,audio,canvas,datalist,details,eventsource,figure,footer,header,hgroup,mark,menu,meter,nav,output,progress,section,time,video";
				// if tags is set, add them to the elements list
				if(tags.length > 0) { e += ','+tags; }
				x = e;
				e = e.split(',');
				i = e.length;
				// loop through the elements and add them to the DOM
				// please note that no jQuery is used here, this due a bug with innerHTML
				while(i--){
					document.createElement(e[i]);
				}
				// create a new style element, insert the CSS rules and put it in the HEAD
				// please note that no jQuery is used here, this due a bug with innerHTML
				s = document.createElement('style');
				s.setAttribute("type", "text/css");
				s.styleSheet.cssText = x + ' {display:block;zoom:1;}';
				h = document.getElementsByTagName('head')[0];
				h.appendChild(s);
			}
		}
	})
})(jQuery);