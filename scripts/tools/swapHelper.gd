@tool
extends MeshInstance3D

func swap_helper(script):
	var script_variables = get_parent().get_script().get_script_property_list()
	var variables_dict = {}
	for variable in script_variables:
		var variable_name = str(variable.name)
		variables_dict[variable_name] = get_parent().get(variable_name)
	get_parent().set_script(script)
	var new_variables = script.get_script_property_list()

	for variable in new_variables:
		if variable.usage & 4 == 4:
			get_parent().set(variable.name, variables_dict[str(variable.name)])
	self.set_script(null)
