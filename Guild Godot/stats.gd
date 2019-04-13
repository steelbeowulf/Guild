extends "Apply.gd"
class_name STATS

# Stats
enum {HP, MP, ATK, ATKM, DEF, DEFM, AGI, LCK}

# Attack type
enum {PHYSIC, MAGIC}

# Status effects
enum{CONFUSION, POISON, BURN, SLOW, HASTE, BERSERK, 
REGEN, UNDEAD, PETRIFY, SILENCE, BLIND, DOOM, PARALYSIS, 
MAX_HP_DOWN, MAX_MP_DOWN, SLEEP, FLOAT, UNKILLABLE, 
INVISIBILITY, REFLECT, CONTROL, CHARM, HP_CRITICAL, CURSE, 
STOP, HIDDEN, FREEZE, IMMOBILIZE, KO, VEIL, TRAPPED}