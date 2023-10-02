extends Node2D

var numCutscenes = 0
var cutsceneDict = {}
var currCutsceneID = 0
var currPageNum = 0
@onready var dialogueBox = $DialogueBox

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if Input.is_action_just_pressed("cutscene_forward"):
			cutscene_forward()

#Loads the first page of a cutscene, and marks it as the current cutscene
func start_cutscene(cutsceneID):
	currCutsceneID = cutsceneID
	currPageNum = 0
	var currCutscene = cutsceneDict[currCutsceneID]
	var currPage = currCutscene[currPageNum]
	dialogueBox.set_dialogue(currPage[0], currPage[1])

#Advances to the next page of the current cutscene. If no more pages are left, hides the cutscene
func cutscene_forward():
	var currCutscene = cutsceneDict[currCutsceneID]
	if(currPageNum + 1 < currCutscene.length()):
		currPageNum += 1
		var currPage = currCutscene[currPageNum]
		dialogueBox.set_dialogue(currPage[0], currPage[1])
	else:
		#emit signal showing cutscene has ended
		pass

#Pushes a new page onto the end of the specified cutscene
func create_cutscene_page(startingPage, cutsceneID, imgPath, dialogueText):
	if(startingPage):
		cutsceneDict[cutsceneID] = []
	cutsceneDict[cutsceneID].insert(cutsceneDict[cutsceneID].size(), [imgPath, dialogueText])

func create_cutscenes():
	pass
