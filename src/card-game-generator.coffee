
mkdirp = require "mkdirp"
async = require "async"
tmp = require "tmp"
fs = require "fs"
path = require "path"
{spawn} = require "child_process"
create_save = require "./create-save"

ts_folder = process.env.TABLETOP_SIMULATOR_FOLDER or "#{process.env.USERPROFILE}/Documents/My Games/Tabletop Simulator"

module.exports =
class CardGameGenerator
	constructor: ({@cardSets, @counters})->
		@cardSets ?= {}
		@counters ?= {}
	
	renderCards: ({page, to, cardWidth, cardHeight, scale, debug}, callback)->
		scale ?= 1

		set_names = ["Back"].concat(Object.keys(@cardSets))
		parallel = process.env.PARALLEL_EXPORT in ["on", "ON", "true", "TRUE", "yes", "YES", "1"]

		(if parallel then async.each else async.eachSeries) set_names,
			(set_name, callback)=>
				n_h = if set_name is "Back" then 1 else 10
				n_v = if set_name is "Back" then 1 else 7
				width = cardWidth * n_h * scale
				height = cardHeight * n_v * scale

				to = path.resolve(to)
				page = path.resolve(page)
				mkdirp to, (err)=>
					return callback err if err
					# TODO: temp CSS file instead?
					# css = """
					# 	body {
					# 		zoom: #{scale};
					# 		text-align: left;
					# 		overflow: hidden;
					# 	}
					# 	body > *:not(.cards),
					# 	section > h1,
					# 	section > h2,
					# 	section > h3,
					# 	section > h4,
					# 	section > h5,
					# 	section > h6,
					# 	.cards > h1,
					# 	.cards > h2,
					# 	.cards > h3,
					# 	.cards > h4,
					# 	.cards > h5,
					# 	.cards > h6 {
					# 		display: none;
					# 	}
					# 	.card {
					# 		margin: 0;
					# 	}
					# """
					tmp.file (err, args_json_file)=>
						return callback err if err
						args_json = JSON.stringify({@cardSets, page, to, cardWidth, cardHeight, scale, debug})
						fs.writeFileSync(args_json_file, args_json, "utf8")
						stderr = ""
						# stdout = ""
						electroshot_args = [page, "#{width}x#{height}", "--out", to, "--filename", "#{set_name}{format}"]
						console.log("spawn electroshot", electroshot_args)
						electroshot_process = spawn("electroshot", electroshot_args)
						electroshot_process.stderr.on "data", (data)->
							stderr += data
							if stderr.indexOf("A JavaScript error occurred in the main process") > -1
								setTimeout -> # allow plenty of time for error message to finish coming in
									# electroshot_process.removeListener "error", callback
									# callback(
									electroshot_process.kill()
								, 500
						# electroshot_process.stdout.on "data", (data)-> stderr += data
						if debug
							electroshot_process.stdout.pipe(process.stdout)
							electroshot_process.stderr.pipe(process.stderr)
						electroshot_process.on "error", callback
						electroshot_process.on "exit", (code, signal)->
							if code is 0 and stderr.indexOf("A JavaScript error occurred in the main process") is -1
								callback()
							else
								callback(new Error("electroshot card renderer process exited #{if signal? then "because of signal #{signal}" else "with code #{code}"} - stderr follows:\n#{stderr}"))
			(error)->
				callback(error)
	
	exportTabletopSimulatorSave: ({to, saveName, imagesURL, renderedImagesURL}, callback)->
		to = path.resolve(to)
		mkdirp to, (err)=>
			return callback err if err
			
			save = create_save({@cardSets, @counters, imagesURL, renderedImagesURL})
			
			@ts_save_json = JSON.stringify(save, null, 2)
			@ts_save_filename = "#{saveName}.json"
			
			fs.writeFile "#{to}/#{@ts_save_filename}", @ts_save_json, "utf8", callback
	
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
