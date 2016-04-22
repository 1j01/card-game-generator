
###
after = (ms, fn)-> setTimeout(fn, ms)
every = (ms, fn)-> setInterval(fn, ms)

$cards = $("<main class='cards'/>").appendTo("body")

render_$card = (data)->
	$card = $("<div class='card'/>")
	
	$card.attr("data-source", source)


$.getJSON "data/cards.json", (cards)->
	
	export_only = location.hash.replace /#/, ""
	
	for set_name, sorted_cards of cards when (not export_only) or export_only is set_name
		$("<h2>").text(set_name).appendTo($cards)
		for card in sorted_cards
			render_$card(card).appendTo($cards)
		if export_only
			$("<div class='card back'/>").appendTo($cards) for [sorted_cards.length...10*7]
	if (not export_only) or export_only is "Back"
		$("<h2>").text("Back").appendTo($cards)
		$("<div class='card back'/>").appendTo($cards)
###
