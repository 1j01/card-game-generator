
# document.title += " (using electron@#{process.versions.electron})"

fs = require "fs"
path = require "path"
async = require "async"
{app, BrowserWindow} = require "electron"

console.log(process.argv, app, BrowserWindow)
# TODO: does argv work in a cross-platform way?
json = fs.readFileSync(process.argv[2], "utf8")
{page, to, cardWidth, cardHeight, scale, debug, cardSets} = JSON.parse(json)

# TODO: figure out card with and height

# css = """
# 	body {
# 		zoom: #{scale};
# 		text-align: left;
# 		overflow: hidden;
# 	}
# 	h2 {
# 		display: none;
# 	}
# 	.card {
# 		margin: 0;
# 	}
# """

options =
	format: "png"
	evalDelay: 14000
	# code: """
	# 	var css = #{JSON.stringify(css)};
	# 	var style = document.createElement('style');
	# 	style.type = 'text/css';
	# 	style.appendChild(document.createTextNode(css));
	# 	document.head.appendChild(style);
	# """
	delay: 0
	encoding: "binary"

merge = (a, b)->
	c = {}
	c[k] = v for k, v of a
	c[k] = v for k, v of b
	c

capture = (url, {width, height, format, evalDelay, code, delay, encoding}, callback)->
	
	# height += 38 if process.platform is "linux"
	
	datatype = if encoding is "base64" then "raw" else "buffer"
	
	# TODO: only show when debugging again
	# https://github.com/nwjs/nw.js/issues/4814
	show = yes #if debug then yes else no
	
	# nw.Window.open url, {width, height, show, frame: no, inject_js_end: code}, (win)->
	nw.Window.open url, {width, height, show, frame: no}, (win)->
		# console.log "got win", win
		# window.console.log "fghgfhgfh?"
		# # win.on "document-end? loaded? loading? nothing works?", ->
		# console.log "loaded"
		# window.console.log "loaded??"
		win.on "focus", ->
			console.log "win focus"
		win.on "document-end", ->
			console.log "win document-end"
		win.on "loaded", ->
			console.log "win loaded"
		win.on "loading", ->
			console.log "win loading"
		
		# console.log win, win.appWindow
		
		# win.appWindow.on "focus", ->
		# 	console.log "win.appWindow focus"
		# win.appWindow.on "document-end", ->
		# 	console.log "win.appWindow document-end"
		# win.appWindow.on "loaded", ->
		# 	console.log "win.appWindow loaded"
		# win.appWindow.on "loading", ->
		# 	console.log "win.appWindow loading"
		
		win.setMaximumSize width * 2, height * 2
		win.width = width
		win.height = height
		# setTimeout ->
		# win.eval null, code if code
		console.log "setTimeout for 2000"
		setTimeout ->
			console.log "capturePage"
			win.capturePage (buffer)->
				console.log "page captured"
				win.close true unless debug
				callback buffer
			, {format, datatype}
		, 2000 #evalDelay
		# , delay

# header = document.createElement("h1")
# document.body.appendChild(header)
# header.textContent = "Rendering cards..."

# set_container = document.createElement("div")
# document.body.appendChild(set_container)

# set_elements = {}

export_set = (set_name, callback)->
	# set_el = set_elements[set_name]
	console.log "Render #{set_name}"
	
	n_h = if set_name is "Back" then 1 else 10
	n_v = if set_name is "Back" then 1 else 7
	
	capture_options = merge options,
		width: cardWidth * n_h * scale
		height: cardHeight * n_v * scale #+ 39 # magic number 39, maybe related to the magic 38 for Linux above?
	
	# capture "file://#{page}##{set_name}", capture_options, (buffer)->
	capture "chrome-extension://#{chrome.runtime.id}/capture.html#file:///#{page}##{set_name}", capture_options, (buffer)->
		console.log "Got some image data for #{set_name}"
		# set_el.classList.remove("rendering")
		# set_el.classList.add("saving")
		file_name = path.join to, "#{set_name}.png"
		fs.writeFile file_name, buffer, (err)->
			return callback err if err
			console.log "Wrote #{file_name}"
			# set_el.classList.add("done")
			callback null
	
	# set_el.classList.add("rendering")

set_names = ["Back"].concat(Object.keys(cardSets))
parallel = process.env.PARALLEL_EXPORT in ["on", "ON", "true", "TRUE", "yes", "YES", "1"]

# for set_name in set_names
# 	set_el = document.createElement("article")
# 	set_el.classList.add("card-set")
	
# 	set_header = document.createElement("h2")
# 	set_header.textContent = set_name
# 	set_el.appendChild(set_header)
	
# 	set_el.indicator = document.createElement("div")
# 	set_el.indicator.classList.add("loader")
# 	set_el.indicator.classList.add("indicator")
# 	set_el.appendChild(set_el.indicator)
	
# 	set_container.appendChild(set_el)
# 	set_elements[set_name] = set_el

(if parallel then async.each else async.eachSeries) set_names, export_set,
	(err)->
		if err
			console.log "failed"
			# document.body.style.color = "red"
			# header.textContent = "Rendering cards failed"
			# document.body.innerHTML += err
			throw err
		else
			console.log "done"
			# setTimeout ->
			# 	if debug
			# 		console.log "staying open because debug mode is on"
			# 	else
			# 		close window
			# , 300
