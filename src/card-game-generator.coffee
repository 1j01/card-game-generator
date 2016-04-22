
mkdirp = require "mkdirp"
tmp = require "tmp"
fs = require "fs"
path = require "path"
{spawn} = require "child_process"
nw = (require "nw").findpath()
create_save = require "./create-save"

# TODO: cross-platform!
ts_folder = "#{process.env.USERPROFILE}/Documents/My Games/Tabletop Simulator"

module.exports =
class CardGameGenerator
	constructor: ({@cardSets, @counters, @imagesURL, @exportedImagesURL, @saveName})->
		@counters ?= {}
	
	export: ({page, exportFolder, cardWidth, cardHeight, scale, debug}, callback)->
		exportFolder = path.resolve(exportFolder)
		page = path.resolve(page)
		mkdirp(exportFolder)
		mkdirp(page)
		args_json = JSON.stringify({@cardSets, page, exportFolder, cardWidth, cardHeight, scale, debug})
		args_json_file = tmp.fileSync().name
		fs.writeFileSync(args_json_file, args_json, "utf8")
		nw_process = spawn(nw, [path.join(__dirname, "../exporter"), args_json_file])
		nw_process.on "error", callback
		nw_process.on "exit", (code)->
			callback() if code is 0
	
	exportToTabletopSimulator: ({exportFolder, saveName})->
		exportFolder = path.resolve(exportFolder)
		
		save = create_save({@imagesURL, @exportedImagesURL, @cardSets})
		
		save_json = JSON.stringify(save, null, 2)
		
		fs.writeFileSync("#{exportFolder}/#{saveName}.json", save_json, "utf8")
		
		chest_folder = "#{ts_folder}/Saves/Chest"
		fs.writeFileSync("#{chest_folder}/#{saveName}.json", save_json, "utf8")
		
		@clearTabletopSimulatorCache()
	
	clearTabletopSimulatorCache: ->
		cache_folder = "#{ts_folder}/Mods/Images"
		for fname in fs.readdirSync cache_folder
			fs.unlinkSync("#{cache_folder}/#{fname}")
