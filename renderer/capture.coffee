
# TODO: use option
scale = 2

css = """
	body {
		zoom: #{scale};
		text-align: left;
		overflow: hidden;
	}
	body > *:not(.cards),
	section > h1,
	section > h2,
	section > h3,
	section > h4,
	section > h5,
	section > h6,
	.cards > h1,
	.cards > h2,
	.cards > h3,
	.cards > h4,
	.cards > h5,
	.cards > h6 {
		display: none;
	}
	.card {
		margin: 0;
	}
"""

iframe = document.querySelector("iframe")
iframe.src = location.hash.replace(/#/, "")
console.log "waiting for iframe onload"
iframe.onload = ->
	doc = iframe.contentDocument
	style = doc.createElement('style')
	style.type = 'text/css'
	style.appendChild(doc.createTextNode(css))
	doc.head.appendChild(style)
	console.log "injected stylesheet", style
