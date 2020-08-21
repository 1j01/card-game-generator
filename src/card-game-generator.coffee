
mkdirp = require "mkdirp"
tmp = require "tmp"
fs = require "fs"
path = require "path"
{spawn} = require "child_process"
electron = require "electron"
create_save = require "./create-save"

ts_folder = process.env.TABLETOP_SIMULATOR_FOLDER or "#{process.env.USERPROFILE}/Documents/My Games/Tabletop Simulator"

module.exports =
class CardGameGenerator
	constructor: ({@cardSets, @counters})->
		@cardSets ?= {}
		@counters ?= {}
	
	renderCards: ({page, to, cardWidth, cardHeight, scale, debug}, callback)->
		scale ?= 1
		to = path.resolve(to)
		page = path.resolve(page)
		mkdirp to, (err)=>
			return callback err if err
			tmp.file (err, args_json_file)=>
				return callback err if err
				args_json = JSON.stringify({@cardSets, page, to, cardWidth, cardHeight, scale, debug})
				fs.writeFileSync(args_json_file, args_json, "utf8")
				# console.log("spawn '#{electron}' with arguments:", [path.join(__dirname, "../renderer"), args_json_file])
				stderr = ""
				# stdout = ""
				electron_process = spawn(electron, [path.join(__dirname, "../renderer"), args_json_file])
				electron_process.stderr.on "data", (data)->
					stderr += data
					if stderr.indexOf("A JavaScript error occurred in the main process") > -1
						setTimeout -> # allow plenty of time for error message to finish coming in
							# electron_process.removeListener "error", callback
							# callback(
							electron_process.kill()
						, 500
				# electron_process.stdout.on "data", (data)-> stderr += data
				if debug
					electron_process.stdout.pipe(process.stdout)
					electron_process.stderr.pipe(process.stderr)
				electron_process.on "error", callback
				electron_process.on "exit", (code, signal)->
					if code is 0 and stderr.indexOf("A JavaScript error occurred in the main process") is -1
						callback()
					else
						callback(new Error("electron card renderer process exited #{if signal? then "because of signal #{signal}" else "with code #{code}"} - stderr follows:\n#{stderr}"))
	
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
