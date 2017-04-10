extends Reference

var object
var path
var old_value
var new_value

func _init(object, path):
	self.object = object
	self.path = path
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
func get_ref():
	var ref = object
	for i in range(path.size()-1):
		ref = ref[path[i]]
	
	return ref
func get_var_name():
	return path[path.size()-1]

func set_old_value():
	old_value = var2bytes(get_var())
func set_new_value():
	new_value = var2bytes(get_var())
func undo():
	var ref = get_ref()
	var var_name = get_var_name()
	var value = bytes2var(old_value)
	if( value != null ): 
		ref[var_name] = value
	else:
		ref.erase(var_name)
func redo():
	var ref = get_ref()
	var var_name = get_var_name()
	var value = bytes2var(new_value)
	if( value != null ): 
		ref[var_name] = value
	else:
		ref.erase(var_name)