//--------------------------------
//------ Global variables -------
//--------------------------------

global tactic;
if(tactic == null) {
	tactic = "hit&run";
}

global attackCombo;
if(attackCombo == null) {
	attackCombo = [];
	
	attackCombo[0] = [];
	attackCombo[0]["type"] = "puce";
	attackCombo[0]["id"] = CHIP_STALACTITE;
	
	attackCombo[1] = [];
	attackCombo[1]["type"] = "weapon";
	attackCombo[1]["id"] = WEAPON_LASER;
	
	attackCombo[2] = [];
	attackCombo[2]["type"] = "puce";
	attackCombo[2]["id"] = CHIP_FLAME;
	
	attackCombo[3] = [];
	attackCombo[3]["type"] = "puce";
	attackCombo[3]["id"] = CHIP_SPARK;
}

global buffCombo;
if(buffCombo == null) {
	buffCombo = [];
	
	buffCombo[0] = [];
	buffCombo[0]["type"] = "puce";
	buffCombo[0]["id"] = CHIP_ARMOR;
	
	buffCombo[1] = [];
	buffCombo[1]["type"] = "puce";
	buffCombo[1]["id"] = CHIP_SHIELD;
	
	buffCombo[2] = [];
	buffCombo[2]["type"] = "puce";
	buffCombo[2]["id"] = CHIP_WALL;
	
	buffCombo[3] = [];
	buffCombo[3]["type"] = "puce";
	buffCombo[3]["id"] = CHIP_HELMET;
}

global healCombo;
if(healCombo == null) {
	healCombo = [];
	
	healCombo[0] = [];
	healCombo[0]["type"] = "puce";
	healCombo[0]["id"] = CHIP_BANDAGE;
}

