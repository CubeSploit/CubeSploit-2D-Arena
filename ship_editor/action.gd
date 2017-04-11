# Action
# Object used to store an action
# An Action object can undo/redo the stored action

extends Reference

# the object containing the data
var object
# path is an array containing the attributes name and array indexes
# to reach the data in the given object
# example: ["attribute_name",1,"attribute_name_2"]
var path
# the byte representation of the old value
var old_value
# the byte representation of the new value
var new_value

func _init(object, path):
	self.object = object
	self.path = path
	
# get_var
# function returning the value pointed by the path
func get_var():
	var ref = object
	for i in range(path.size()):
		if( typeof(ref) == TYPE_DICTIONARY && ref.has(path[i]) || 
		typeof(ref) == TYPE_ARRAY && ref.size() > path[i] ||
		typeof(ref) == TYPE_OBJECT && ref.get(path[i]) != null ):
			ref = ref[path[i]]
		else:
			return null
		
	return ref
# get_ref
# function returning to object/dic/array containing the value
func get_ref():
	var ref = object
	for i in range(path.size()-1):
		ref = ref[path[i]]
	
	return ref
# get_var_name
# function returning the data value's name/index in the ref
func get_var_name():
	return path[path.size()-1]

# set_old_value
# get the current value of the data and save it as an array of bytes
# set it as old value
func set_old_value():
	old_value = var2bytes(get_var())
# set_new_value
# get the current value of the data and save it as an array of bytes
# set it as new value
func set_new_value():
	new_value = var2bytes(get_var())
	
# undo
# Replace the current value of the concerned data with the old value
func undo():
	var ref = get_ref()
	var var_name = get_var_name()
	var value = bytes2var(old_value)
	if( value != null ): 
		if( typeof(ref) == TYPE_ARRAY ):
			ref.insert(var_name, value)
		else:
			ref[var_name] = value
	else:
		if( typeof(ref) == TYPE_DICTIONARY ):
			ref.erase(var_name)
		elif( typeof(ref) == TYPE_ARRAY ):
			ref.remove(var_name)
# redo
# Replace the current value of the concerned data with the new value
func redo():
	var ref = get_ref()
	var var_name = get_var_name()
	var value = bytes2var(new_value)
	if( value != null ): 
		if( typeof(ref) == TYPE_ARRAY ):
			ref.insert(var_name, value)
		else:
			ref[var_name] = value
	else:
		if( typeof(ref) == TYPE_DICTIONARY ):
			ref.erase(var_name)
		elif( typeof(ref) == TYPE_ARRAY ):
			ref.remove(var_name)