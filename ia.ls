include("globals.ls");
include("functions.ls");

//--------------------------------
//------- Code de base -----------
//--------------------------------

// --- Variables ---
var me = getLeek();
var enemy = getRealNearestEnemy(me);
var turn = getTurn();
var weapon = getWeapon();


// --- Code ---

// On prend le pistolet
if(weapon == null) {
	setWeapon(WEAPON_LASER);
	weapon = WEAPON_LASER;
}

// Invoque le poireau sur une case juste à côté de toi.
if(turn == 1) {
   summon(CHIP_PUNY_BULB , getCellToUseChip(CHIP_PUNY_BULB, me), IA_bulbe);
}

if(weapon != WEAPON_AXE) {
	if(canGoCac(me, enemy)) {
		setWeapon(WEAPON_AXE);
		attackCombo[1]["id"] = WEAPON_AXE;
		tactic = "rush";
	}
}

if(turn > 50) tactic = "rush";

if(UseProtectionFirstTime(enemy) && getLife(enemy) > 100) {
	// On utilise le combo de buff
	useComboOnMe(buffCombo, me);
}

// On utilise le combo d'attaque
useAttackCombo(attackCombo, enemy, tactic);

// On se rapproche en restant en zone safe
tacticMoveToward(enemy, tactic);

if(turn > 2) {
	// On utilise le combo de buff
	useComboOnMe(buffCombo, me);
}

// On se heal si nécessaire
if( getTotalLife() != getLife() ) useComboOnMe(buffCombo, me);

say(menace(enemy));
