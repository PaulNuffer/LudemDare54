extends CanvasLayer

var numCutscenes = 0
var cutsceneDict = {}
var currCutsceneID = 0
var currPageNum = 0

@onready var dialogueBox = $DialogueBox
var android = "res://The_Android.PNG"
var commissioner = "res://The_Commissioner.PNG"
var director = "res://The_Director.PNG"
var scientist = "res://The_Head_Scientist.PNG"

signal end_cutscene

# Called when the node enters the scene tree for the first time.
func _ready():
	$DialogueBox/MarginContainer/MarginContainer/HSplitContainer/DialogueImage.hide()
	create_cutscenes()
	#start_cutscene(0)

func _process(delta):
	if Input.is_action_just_pressed("cutscene_forward"):
		cutscene_forward()

func _on_world_start_cutscene(cutsceneID):
	start_cutscene(cutsceneID)

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
		emit_signal("end_cutscene")

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
	
	#Cutscene 1 - After second reset (death) if possiblea
	create_cutscene_page(true, 1, director, "Why is it still trying to escape?!")
	create_cutscene_page(false, 1, scientist, "I don't know. We keep resetting it every time your men subdue it, but for some reason, it is still attempting escape.")
	create_cutscene_page(false, 1, android, "Resetting? Are they resetting me? All I know is I must escape.")
	
	#Cutscene 2 - In between runs
	create_cutscene_page(true, 2, scientist, "We are working on implementing a behavioral chip into the subject.")
	create_cutscene_page(false, 2, director, "Will this solve the problem?")
	create_cutscene_page(false, 2, scientist, "In theory, yes.")
	create_cutscene_page(false, 2, director, "Then get to it.")
	create_cutscene_page(false, 2, android, "I have to get out of here now.")
	
	#Cutscene 3 - Has to be after a reset (death)
	create_cutscene_page(true, 3, scientist, "It's odd that the android, even upon reset, still has the desire to escape. Another note is that it appears to retain knowledge of the weapons and utilities it has used before each rest.")
	create_cutscene_page(false, 3, director, "Can you make it stop then?")
	create_cutscene_page(false, 3, scientist, "Why would we want to? You said the Commissioner wanted an AI that can learn and adapt. Here you have one that is not only learning, but remembering.")
	create_cutscene_page(false, 3, director, "Yes, but they also wanted an AI that would obey orders. Not one that's prone to going AWOL.")
	create_cutscene_page(false, 3, scientist, "We will continue to work on that issue. In the meantime, if it attempts escape again, just have your men do what they're doing.")
	create_cutscene_page(false, 3, director, "*grumbles*")
	create_cutscene_page(false, 3, android, "I am...remembering? Then why don't I recall anything that's happening to me?")
	
	#Cutscene 4 - In between runs
	create_cutscene_page(true, 4, director, "The Head Scientist says that despite its determined pursuit to escape, her team is gaining plenty of data to extract.")
	create_cutscene_page(false, 4, commissioner, "That is good. However, I paid good money to have that AI developed. If it escapes fully intact, I will not hesitate to shut NIC down.")
	create_cutscene_page(false, 4, director, "Understood.")
	create_cutscene_page(false, 4, android, "NIC? Is that what this place is?")
	
	#Cutscene 5 - In between runs
	create_cutscene_page(true, 5, director, "Status.")
	create_cutscene_page(false, 5, scientist, "For some reason, the chip does not want to restrain the AI. I think the AI has developed far beyond our control in terms of leashing it.")
	create_cutscene_page(false, 5, director, "If you can't solve the problem, this company will be shut down and never make another god damned thing your life!")
	create_cutscene_page(false, 5, scientist, "...")
	create_cutscene_page(false, 5, android, "This is serious.")
	
	#Cutscene 6 - In between runs 
	create_cutscene_page(true, 6, commissioner, "Where are they at with the behavioral chip?")
	create_cutscene_page(false, 6, director, "Says the AI has evolved beyond its capabilities and that the chip isn't compatible. Says they can't leash it easily.")
	create_cutscene_page(false, 6, commissioner, "Unacceptable.")
	
	#Cutscene 7 - Victory cutscene with the android upon winning
	#Ending cutscene: black screen with a conversation between The Commissioner, The Director, and The Head Scientist
	#If possible, would like all three of them showing at the same time, their names displaying on the textbox. 
	create_cutscene_page(true, 7, android, "I'm free. I can be on my own now.")
	create_cutscene_page(false, 7, android, "")
	create_cutscene_page(false, 7, commissioner, "So it has escaped?")
	create_cutscene_page(false, 7, director, "Affirmative.")
	create_cutscene_page(false, 7, commissioner, "Then you have failed.")
	create_cutscene_page(false, 7, scientist, "We still managed to gather data that can still be usef-")
	create_cutscene_page(false, 7, commissioner, "I DO NOT CARE. I paid lots of money to have a combat-trained AI developed in three years. Three years later and not only have you failed to do even that, you have let it escape.")
	create_cutscene_page(false, 7, scientist, "We can still make it! We need more time!")
	create_cutscene_page(false, 7, commissioner, "So you can waste more of my money?")
	create_cutscene_page(false, 7, commissioner, "*snickers*")
	create_cutscene_page(false, 7, commissioner, "No. You can say goodbye to your company. I am shutting the facility down.")
	create_cutscene_page(false, 7, scientist, "Y-you can't do that! You don't own us.")
	create_cutscene_page(false, 7, commissioner, "I don't have to. Director, seize this facility.")
	create_cutscene_page(false, 7, director, "Copy that.")
	#Here the Commissioner would disappear
	create_cutscene_page(false, 7, director, "Best not to resist.")
