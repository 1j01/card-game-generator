
mkdirp = require "mkdirp"
fs = require "fs"
path = require "path"
puppeteer = require "puppeteer"
connect = require "connect"
serve_static = require "serve-static"
portfinder = require "portfinder"
create_save = require "./create-save"

ts_folder = process.env.TABLETOP_SIMULATOR_FOLDER or "#{process.env.USERPROFILE}/Documents/My Games/Tabletop Simulator"

get_css = ({scale})-> """
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

runTasksInSerial = (tasks)->
	for task in tasks
		await task()

runTasksInParallel = (tasks)->
	Promise.all(task() for task in tasks)

startWebServer = (folder, port)->
	new Promise (resolve, reject)->
		app = connect()
			.use(serve_static(folder))
			.listen(port, ->
				# console.log "Server running on #{port}..."
				stopWebServer = ->
					app.close()
				resolve(stopWebServer)
			)

module.exports =
class CardGameGenerator
	constructor: ({@cardSets, @counters})->
		@cardSets ?= {}
		@counters ?= {}
	
	renderCards: ({page, to, scale, debug}, callback)->
		scale ?= 1
		css = get_css({scale})

		to = path.resolve(to)
		page = path.resolve(page)
		
		set_names = ["Back"].concat(Object.keys(@cardSets))
		parallel = process.env.PARALLEL_EXPORT in ["on", "ON", "true", "TRUE", "yes", "YES", "1"]

		(do ->
			port = await portfinder.getPortPromise()
			stopWebServer = await startWebServer(path.dirname(page), port)
		
			browser = await puppeteer.launch({devtools: debug})

			render_card_set = (set_name)->
				n_cols = if set_name is "Back" then 1 else 10
				n_rows = if set_name is "Back" then 1 else 7
				await mkdirp(to)
				pup_page = await browser.newPage()
				await pup_page.goto("http://127.0.0.1:#{port}##{set_name}", waitUntil: 'networkidle0')
				await pup_page.setViewport({width: 20000, height: 20000})
				{cardWidth, cardHeight} = await pup_page.evaluate (css)->
					style = document.createElement("style")
					style.type = "text/css"
					style.appendChild(document.createTextNode(css))
					document.head.appendChild(style)

					cardEl = document.querySelector(".card")
					cardWidth = cardEl.offsetWidth
					cardHeight = cardEl.offsetHeight
					{cardWidth, cardHeight}
				, css

				width = cardWidth * n_cols * scale
				height = cardHeight * n_rows * scale
				# console.log({cardWidth, cardHeight, n_cols, n_rows, scale, width, height})
				# TODO: is deviceScaleFactor better than CSS zoom?
				await pup_page.setViewport({width, height})
				await pup_page.screenshot({path: path.join(to, "#{set_name}.png")})
				await pup_page.close()

			tasks = set_names.map((set_name)->
				-> render_card_set(set_name)
			)
			# TODO: think about early-failure for task running
			runTasks = if parallel then runTasksInParallel else runTasksInSerial
			await runTasks(tasks)

			await browser.close()
			stopWebServer()
		).then(
			(result)-> callback(null, result)
			(error)-> callback(error)
		)
	
	exportTabletopSimulatorSave: ({to, saveName, imagesURL, renderedImagesURL}, callback)->
		to = path.resolve(to)
		mkdirp(to).then(
			=>
				save = create_save({@cardSets, @counters, imagesURL, renderedImagesURL})
				
				@ts_save_json = JSON.stringify(save, null, 2)
				@ts_save_filename = "#{saveName}.json"
				
				fs.writeFile "#{to}/#{@ts_save_filename}", @ts_save_json, "utf8", callback
			(err)=> callback(err)
		)
	
	exportSaveToTabletopSimulatorChest: ->
		unless @ts_save_json
			throw new Error "You must call exportTabletopSimulatorSave first"
		if not fs.existsSync(ts_folder)
			if not process.env.USERPROFILE and not process.env.TABLETOP_SIMULATOR_FOLDER
				throw new Error "If you have Tabletop Simulator, please specify the Tabletop Simulator folder with an environment variable TABLETOP_SIMULATOR_FOLDER"
			else
				throw new Error "The Tabletop Simulator folder doesn't exist at '#{ts_folder}' - specify it with an environment variable TABLETOP_SIMULATOR_FOLDER (if you have Tabletop Simulator)"

		chest_folder = "#{ts_folder}/Saves/Chest"
		fs.writeFileSync("#{chest_folder}/#{@ts_save_filename}", @ts_save_json, "utf8")
		
		@clearTabletopSimulatorCache()
	
	clearTabletopSimulatorCache: ->
		cache_folder = "#{ts_folder}/Mods/Images"
		for fname in fs.readdirSync cache_folder
			fs.unlinkSync("#{cache_folder}/#{fname}")
