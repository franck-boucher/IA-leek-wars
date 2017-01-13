//--------------------------------
//--------- Fonctions -------------
//--------------------------------
global phrases = [
    "Tu es cuit [leek] !",
    "Tu vas finir en vinaigrette [leek] !",
    "Les carottes sont cuites [leek] !",
    "je vais te tailler en julienne [leek] !",
    "Je vais t'assaisonner [leek] !"
];
global attackChip = [
	CHIP_SPARK,
	CHIP_ICE,
	CHIP_ROCK
];

function menace(ennemy){
    var phrase = random(phrases);
    return replace(phrase, "[leek]", getName(ennemy));
}
function random(array){
    return array[randInt(0, count(array))];
}

function tacticMoveToward(enemy, strat) {
	if(strat == "rush") moveToward(enemy, enemy);
	else moveToward(enemy, getMaxMPToSafeMove(enemy));
}

function getRealNearestEnemy(me){
	var nearestEnemy = getNearestEnemy();
	var nbEnemy = getAliveEnemiesCount();
	if(!isSummon(nearestEnemy) or nbEnemy <= 1) return nearestEnemy;
	
	var secondNearestEnemy = getNearestEnemyTo(nearestEnemy);
	if(!isSummon(secondNearestEnemy)) return secondNearestEnemy;
	
	var enemies = getAliveEnemies();
	var realNearestEnemy = nearestEnemy;
	var realNearestEnemyDistance = 1000;
	for(var enemy in enemies) {
		if(enemy != nearestEnemy and enemy != secondNearestEnemy) {
			var enemyDistance = getCellDistance(me, enemy);
			if(enemyDistance < realNearestEnemyDistance) {
				realNearestEnemy = enemy;
				realNearestEnemyDistance = enemyDistance;
			}
		}
	}
	return realNearestEnemy;
}

function canGoCac(me, enemy){
	return getCellDistance(getCell(me), getCell(enemy)) <= getMP(me);
}

function useAttackCombo(combo, enemy, strat){
	for(var comboItem in combo) {
		if(comboItem["type"] == "puce") {
			var cellToPuce = canMoveAttackWithChip(comboItem["id"], enemy);
			if(cellToPuce != false) {
				moveTowardCell(cellToPuce);
				attackWithChip(comboItem["id"], enemy);
				if(strat == "rush") moveToward(enemy);
				else moveAwayFrom(enemy);
			}
		}
		if(comboItem["type"] == "weapon") {
			var cellToWeapon = canMoveAttackWithWeapon(comboItem["id"], enemy);
			debug(cellToWeapon);
			if(cellToWeapon != false) {
				moveTowardCell(cellToWeapon);
				attack(comboItem["id"], enemy);
				moveAwayFrom(enemy);
			}
		}
	}
}

function useComboOnMe(combo, me){
	for(var comboItem in combo) {
		attackWithChip(comboItem["id"], me);
	}
}

function attack(weapon, enemy) {
		useWeapon(enemy);
		useWeapon(enemy);
}
function attackWithChip(chip, enemy) {
		useChip(chip, enemy);
		useChip(chip, enemy);
		useChip(chip, enemy);
}

// Renvoi une cellule atteignable où l'on peut tirer sur un ennemi, sinon renvoi false
function canMoveAttackWithWeapon(weapon, enemyLeek) {
	// Si on peut déjà lui tirer dessus c'est pas la peine de calculer
	if(canUseWeapon(weapon, enemyLeek)) return getCell();
	var remainingMP = getMP();
	var myCell = getCell();
	var distance = getCellDistance(myCell, getCell(enemyLeek));
	// Si l'ennemi est bien a notre portée théorique
	if(distance <= remainingMP + getWeaponMaxRange(weapon)) {
		var cells = getCellsToUseWeapon(weapon, enemyLeek);
		for(var i = 0; i < count(cells); i++) {
			var pathLength = getPathLength(myCell, cells[i]);
			if(pathLength <= remainingMP) return cells[i];
		}
	}
	return false;
}

// Renvoi une cellule atteignable où l'on peut pucer un ennemi, sinon renvoi false
function canMoveAttackWithChip(chip, enemyLeek) {
	// Si on peut déjà le pucer dessus c'est pas la peine de calculer
	if(canUseChip(chip, enemyLeek)) return getCell();
	var remainingMP = getMP();
	var myCell = getCell();
	var distance = getCellDistance(myCell, getCell(enemyLeek));
	// Si l'ennemi est bien a notre portée théorique
	if(distance <= remainingMP + getChipMaxRange(chip)) {
		var cells = getCellsToUseChip(chip, enemyLeek);
		for(var i = 0; i < count(cells); i++) {
			var pathLength = getPathLength(myCell, cells[i]);
			if(pathLength <= remainingMP) return cells[i];
		}
	}
	return false;
}

// Fonction qui retourne le nombre de PT minimum des puces/armes d'un poireau
function getMinAttackCost(leek){
	var minTP = getTotalTP();
	// On check l'arme équipée
	var weapon = getWeapon(leek);
	if(getWeaponCost(weapon) < minTP) minTP = getWeaponCost(weapon);
	// On boucle sur les puces
	for(var chip in attackChip){
		if(getChipCost(chip) < minTP) minTP = getChipCost(chip);
	}
	return minTP;
}

// Fonction qui retourne le nombre de PT minimum des puces/armes d'un combo
function getMinAttackCostCombo(combo){
	var minTP = getTotalTP();
	for(var comboItem in combo) {
		if(comboItem["type"] == "puce") {
			var chipCost = getChipCost(comboItem["id"]);
			if(chipCost < minTP) minTP = chipCost;
		}
		if(comboItem["type"] == "weapon") {
			var weaponCost = getWeaponCost(comboItem["id"]);
			if(weaponCost < minTP) minTP = weaponCost;
		}
	}
	return minTP;
}

// Fonction qui retourne la portée maximale des puces/armes d'un poireau
function getMaxRange(leek){
	var maxRange = 0;
	// On boucle sur les armes
	for(var weapon in getWeapons(leek)){
		if(getWeaponMaxRange(weapon) > maxRange) maxRange = getWeaponMaxRange(weapon);
	}
	// On boucle sur les puces
	for(var chip in attackChip){
		if(getChipMaxRange(chip) > maxRange) maxRange = getChipMaxRange(chip);
	}
	return maxRange;
}

// Fonction qui retourne le nombre maximal de PM qu'il faut utiliser pour ne pas se faire toucher au prochain tour
// Retourne 0 si le résulta est négatif
function getMaxMPToSafeMove(enemyLeek){
	var maxRange = getMaxRange(enemyLeek); // Portée maximale
	var maxRangeNextTurn = maxRange + getMP(enemyLeek); // Portée maximale du prochain tour
	var distance = getCellDistance(getCell(), getCell(enemyLeek)); // Distance entre les poireaux
	var maxPMSafe = distance - (maxRangeNextTurn + 1); // +1 car la portée commence à 0
	return max(0,maxPMSafe);
}

function UseProtectionFirstTime(enemyLeek){
    var val = false;
    //debug(getMaxMPToSafeMove(enemyLeek));
    //debug(getMaxRange(enemyLeek));
    if ( (getMaxMPToSafeMove(enemyLeek) > 0) && ( getMaxMPToSafeMove(enemyLeek) < 6 ) ) {
    //if ( getMaxMPToSafeMove(enemyLeek) <= 6 ) {
        val = true;
    }
    return val;
}
function UseProtectionBeforeFirstTime(enemyLeek){
    var val = false;
    //debug(getMaxMPToSafeMove(enemyLeek));
    //debug(getMaxRange(enemyLeek));
    if ( (getMaxMPToSafeMove(enemyLeek) >= 6) && ( getMaxMPToSafeMove(enemyLeek) <= 12 ) ) {
    //if ( getMaxMPToSafeMove(enemyLeek) <= 6 ) {
        val = true;
    }
    return val;
}

//Bulbe
//IA d'un bulbe lanceur de cailloux.
function IA_bulbe() {
    // invocation var me = getLeek();
    var iko = getSummoner();
    var enemy = getNearestEnemy();
    useChip(CHIP_PROTEIN, iko);
    useChip(CHIP_HELMET, iko);    
    //if( getTotalLife(iko) != getLife(iko) ) useChip(CHIP_BANDAGE, iko);
    attackWithChip(CHIP_PEBBLE, enemy);
    useChip(CHIP_BANDAGE, iko);    
    say(menace(enemy));
    say(menace(enemy));
    say(menace(enemy));
    say(menace(enemy));
    if (getTurn()>51) { 
        moveToward(enemy);
        attackWithChip(CHIP_PEBBLE, enemy);        
    }
    moveToward(iko,2);    
    moveToward(enemy, 1);
}