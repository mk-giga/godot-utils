
#  ██████╗ ██████╗       ███████╗████████╗ █████╗ ████████╗
# ██╔════╝ ██╔══██╗      ██╔════╝╚══██╔══╝██╔══██╗╚══██╔══╝
# ██║  ███╗██║  ██║█████╗███████╗   ██║   ███████║   ██║   
# ██║   ██║██║  ██║╚════╝╚════██║   ██║   ██╔══██║   ██║   
# ╚██████╔╝██████╔╝      ███████║   ██║   ██║  ██║   ██║   
#  ╚═════╝ ╚═════╝       ╚══════╝   ╚═╝   ╚═╝  ╚═╝   ╚═╝   
#
#   a free stat system for godot
#   by mk-giga
#

#########################################################################
# this resource represents a [current / max] stat such as hp, mana, ... #
# ... or anything that can have a current and a maximum value.          #
#########################################################################

@tool
class_name Stat extends Node

## Emitted when the stat's [i]current[/i] variable changes.
signal on_changed(old_value, new_value)

## Emitted when the stat's [i]current[/i] value reaches 0 or below.
signal on_depleted

## The name of your stat, such as "Health", "Strength", "Coolness", "Fuel", "Patience", etc ...
@export var stat_name: str = "Coolness"

## The base value, also known as its max value.
@export var base: int = 100

## The current value. If this goes below 0, the stat is considered depleted, and [member on_depleted] will be emitted.
@export var current: int = 100

## Can the [member current] overflow above its base/max value?
@export var allow_over_max: bool = false

## Should the [member current] value be allowed to go under 0?
## If false, any change to the stat that would result in a negative number will instead set it to 0.
## [br]
## [br]
## For example, if 
@export var allow_under_zero: bool = false

func _ready():
    pass

## Constructor method that gets called when you write 
func _init(
            base: int = (self.base if self.base not null else 100), 
            current: int = (self.current if self.current not null else 100), 
            allow_over_max: bool = (self.allow_over_max if self.allow_over_max not null, else false), 
            allow_under_zero: bool = (self.allow_under_zero if self.allow_under_zero not null, else false)):

    self.base = base
    self.current = current
    self.allow_over_max = allow_over_max

## Sets the stat's current variable. Returns the difference (the old value - the new value).
func set_current(val: int = self.current) -> int:
    var old_value = current
    var new_value = current + val

    if new_value == current:
        return 0

    if new_value <= 0:
        current = 0
    elif not val == 0:
        on_changed.emit(current, current)

## Adds to the stat's [member current] value by [param val]. Passing in a negative number will decrease it instead.
func increase_by(val: int) -> int:
    return alter(val)

## Subtracts the stat's [member current] value by [param val]. [WARBUBGF] Passing in a negative number will increase it instead.
func decrease_by(val: int) -> int:
    return alter(-val)

## Adds [param val] to the current variable's value. Pass in a positive value to add, or a negative value to subtract.
##
## Example:
## [codeblock]
## func attack_npc(npc, damage):
##     var npc_hp: Stat = npc.hp
##     npc_hp.change(-damage)
## [/codeblock]
func alter(val: int = current) -> int:
    var old_value = current
    var new_value = current + val

    if (new_value <= base) and (new_value > 0):
        current = new_value;
    else:
        
        if (new_value > base)
            if allow_over_max:
                current = new_value
            else:
                current = base

        elif (new_value <= 0):
            if allow_under_zero:
                current = new_value
            else:
                current = 0
    
    _check_emit_changed(old_value, current)

    # return the resulting difference
    return (old_value - current)

## Checks if the [member current] value has changed and emits [member on_changed] if true.
func _check_emit_changed(old_value: int, new_value: int) -> void:

    var has_changed: bool = (old_value != new_value)
    var is_depleted: bool = false if new_value < 0 else true

    # if the value of our stat has not changed, return early
    if not has_changed:
        return
    
    # ... else, go ahead and emit signals
    on_changed.emit(old_value, new_value)
    
    if is_depleted:
        on_depleted.emit()
