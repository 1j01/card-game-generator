
gui = require "nw.gui"
fs = require "fs"
async = require "async"

json = fs.readFileSync(gui.App.argv[0], "utf8")
{page, exportFolder, cardWidth, cardHeight, scale, debug, cardSets} = JSON.parse(json)

css = """
	body {
		zoom: #{scale};
		text-align: left;
		overflow: hidden;
	}
	h2 {
		display: none;
	}
	.card {
		margin: 0;
	}
"""

options =
	format: "png"
	evalDelay: 14000
	code: """
		var css = #{JSON.stringify(css)};
		var style = document.createElement('style');
		style.type = 'text/css';
		style.appendChild(document.createTextNode(css));
		document.head.appendChild(style);
	"""
	delay: 500
	encoding: "binary"

merge = (a, b)->
	c = {}
	c[k] = v for k, v of a
	c[k] = v for k, v of b
	c

capture = (url, {width, height, format, evalDelay, code, delay, encoding}, callback)->
	
	height += 38 if process.platform is "linux"
	
	datatype = if encoding is "base64" then "raw" else "buffer"
	
	show = if debug then yes else no
	gui.Window.get().show() if show
	
	win = gui.Window.open url, {width, height, show, frame: show}
	
	win.once "document-end", ->
		win.setMaximumSize width * 2, height * 2
		win.width = width
		win.height = height
		setTimeout ->
			win.eval null, code if code
			setTimeout ->
				win.capturePage (buffer)->
					win.close true unless debug
					callback buffer
				, {format, datatype}
			, evalDelay
		, delay

export_set = (set_name, callback)->
	console.log "Export #{set_name}"
	setTimeout ->
		
		n_h = if set_name is "Back" then 1 else 10
		n_v = if set_name is "Back" then 1 else 7
		
		capture_options = merge options,
			width: cardWidth * n_h * scale
			height: cardHeight * n_v * scale + 39 # magic number 39, maybe related to the magic 38 for Linux above?
		
		capture "file://#{page}##{set_name}", capture_options, (buffer)->
			console.log "Got some image data for #{set_name}"
			file_name = "#{exportFolder}/#{set_name}.png"
			fs.writeFile file_name, buffer, (err)->
				return callback err if err
				console.log "Wrote #{file_name}"
				callback null
	, 5000

set_names = ["Back"].concat(Object.keys(cardSets))
parallel = process.env.PARALLEL_EXPORT in ["on", "ON", "true", "TRUE", "yes", "YES", "1"]

(if parallel then async.each else async.eachSeries) set_names, export_set,
	(err)->
		if err
			document.body.style.background = "red"
			throw err
		console.log "done"
		gui.Window.get().close true
