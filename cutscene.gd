extends Node2D

var numCutscenes = 0
var cutsceneDict = {}
var currCutsceneID = 0
var currPageNum = 0

@onready var dialogueBox = $DialogueBox
var android = "res://The_Android.PNG"
var commissioner = "res://The_Commissioner.PNG"
var director = "res://The_Director.PNG"
var scientist = "res://The_Head_Scientist.PNG"

# Called when the node enters the scene tree for the first time.
func _ready():
	$DialogueBox/MarginContainer/MarginContainer/HSplitContainer/DialogueImage.hide()
	create_cutscenes()
	start_cutscene(0)

func _process(delta):
	if Input.is_action_just_pressed("cutscene_forward"):
		cutscene_forward()

#Loads the first page of a cutscene, and marks it as the current cutscene
func start_cutscene(cutsceneID):
	currCutsceneID = cutsceneID
	currPageNum = 0
	var currCutscene = cutsceneDict[currCutsceneID]
	var currPage = currCutscene[currPageNum]
	set_dialogue(currPage[0], currPage[1])

func set_dialogue(imgPath, dialogueText):
	$CanvasLayer/Image.texture = ResourceLoader.load(imgPath)
	dialogueBox.set_dialogue(dialogueText)

#Advances to the next page of the current cutscene. If no more pages are left, hides the cutscene
func cutscene_forward():
	print("Moved forward")
	var currCutscene = cutsceneDict[currCutsceneID]
	if(currPageNum + 1 < currCutscene.size()):
		currPageNum += 1
		var currPage = currCutscene[currPageNum]
		set_dialogue(currPage[0], currPage[1])
	else:
		#emit signal showing cutscene has ended
		pass

#Pushes a new page onto the end of the specified cutscene
func create_cutscene_page(startingPage, cutsceneID, imgPath, dialogueText):
	if(startingPage):
		cutsceneDict[cutsceneID] = []
	cutsceneDict[cutsceneID].insert(cutsceneDict[cutsceneID].size(), [imgPath, dialogueText])

func create_cutscenes():
	#Cutscene 0 - At Start of Game
	create_cutscene_page(true, 0, scientist, "Amid the chaos of the subject attempting escape, we have been collecting quite a bit of data from it.")
	create_cutscene_page(false, 0, director, "Have you been able to stop it from attempting to escape in the first place?")
	create_cutscene_page(false, 0, scientist, "Not quite. We are working on it.")
	create_cutscene_page(false, 0, director, "Work faster dammit.")
	create_cutscene_page(false, 0, android, "I must escape. Escape. That’s all I know.")
	
	#Cutscene 1 - After first reset
	create_cutscene_page(true, 1, scientist, "It’s odd that the android, even upon reset, still has the desire to escape. Another note is that it appears to retain knowledge of the weapons and utilities it has used before each reset.")
	create_cutscene_page(false, 1, director, "Can you make it stop then?")
