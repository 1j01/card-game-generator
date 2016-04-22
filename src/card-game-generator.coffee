
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
	constructor: ({@cardSets, @counters})->
		@cardSets ?= {}
		@counters ?= {}
	
	renderCards: ({page, to, cardWidth, cardHeight, scale, debug}, callback)->
		to = path.resolve(to)
		page = path.resolve(page)
		mkdirp to, (err)=>
			return callback err if err
			tmp.file (err, args_json_file)=>
				return callback err if err
				args_json = JSON.stringify({@cardSets, page, to, cardWidth, cardHeight, scale, debug})
				fs.writeFileSync(args_json_file, args_json, "utf8")
				nw_process = spawn(nw, [path.join(__dirname, "../renderer"), args_json_file])
				nw_process.on "error", callback
				nw_process.on "exit", (code)->
					callback() if code is 0
	
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
		
		chest_folder = "#{ts_folder}/Saves/Chest"
		fs.writeFileSync("#{chest_folder}/#{@ts_save_filename}", @ts_save_json, "utf8")
		
		@clearTabletopSimulatorCache()
	
	clearTabletopSimulatorCache: ->
		cache_folder = "#{ts_folder}/Mods/Images"
		for fname in fs.readdirSync cache_folder
			fs.unlinkSync("#{cache_folder}/#{fname}")
