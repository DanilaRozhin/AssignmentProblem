extends Control

@onready var currentMatrix = $"Margins/Branch&BoundMethod/ScrollMatrix&Tree/Matrix&Tree/Matrix/Matrix"

@onready var buttonConfirm = $"Margins/Branch&BoundMethod/Buttons/MarginsButtons/Confirm"
@onready var buttonNext = $"Margins/Branch&BoundMethod/Buttons/MarginsButtons/Next"

@onready var editMatrixSize = $"Margins/Branch&BoundMethod/MatrixSize/EditMatrixSize"
@onready var information = $"Margins/Branch&BoundMethod/Information"
@onready var nextArrow = $"Margins/Branch&BoundMethod/ScrollMatrix&Tree/Matrix&Tree/----->"
@onready var presets = $"Margins/Branch&BoundMethod/MatrixSize/Presets"

var pathCurrentMatrix = "Margins/Branch&BoundMethod/ScrollMatrix&Tree/Matrix&Tree/Matrix"
var pathTree = "Margins/Branch&BoundMethod/ScrollMatrix&Tree/Matrix&Tree/Tree"



func create_base_matrix(matrixSize) -> Array:
	var resultMatrix = []
	resultMatrix.resize(matrixSize)
	
	for numRow in range(matrixSize):
		resultMatrix[numRow] = []
		resultMatrix[numRow].resize(matrixSize)

	var numberElement = 0
	
	for numRow in range(matrixSize):
		for numColumn in range(matrixSize):
			resultMatrix[numRow][numColumn] = int(get_node(pathCurrentMatrix + "/Matrix").get_child(numberElement).text)
			numberElement += 1
	
	return resultMatrix


func search_min_value_in_column(matrix, numberColumn) -> int:
	var minValue = matrix[0][numberColumn]
	
	for numRow in range(matrix.size()):
		if matrix[numRow][numberColumn] < minValue:
			minValue = matrix[numRow][numberColumn]
	
	return minValue


func create_line_edit(isEditable) -> LineEdit:
	var lineEdit = LineEdit.new()
	
	if isEditable:
		lineEdit.focus_mode = FOCUS_ALL
	else:
		lineEdit.focus_mode = FOCUS_NONE
	
	lineEdit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	lineEdit.editable = isEditable
	lineEdit.virtual_keyboard_enabled = isEditable
	lineEdit.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER
	lineEdit.caret_blink = true
	lineEdit.custom_minimum_size.x = 75
	lineEdit.custom_minimum_size.y = 75
	lineEdit.add_theme_font_override("font", load("res://Fonts/LatoBlackItalic.ttf"))
	lineEdit.add_theme_font_size_override("font_size", 20)
	lineEdit.set("theme_override_colors/font_color", Color.WHITE)
	lineEdit.set("theme_override_colors/font_uneditable_color", Color.WHITE)
	lineEdit.set("theme_override_colors/font_outline_color", Color.BLACK)
	lineEdit.set("theme_override_constants/outline_size", 5)
	return lineEdit


func add_elements_in_matrix(numberElements, isEditable, matrix) -> void:
	var element = create_line_edit(isEditable)
	
	for numberElement in range(numberElements):
		var elem = element.duplicate()
		elem.name = "Element" + str(numberElement + 1)
		get_node(matrix).add_child(elem)


func add_elements_in_additional_fields(numberElements):
	var element = create_line_edit(false)
	
	for numberElement in range(numberElements):
		var elem = element.duplicate()
		elem.name = "Element" + str(numberElement + 1)
		get_node(pathCurrentMatrix + "/AdditionalColumn").add_child(elem)
	
	for numberElement in range(numberElements):
		var elem = element.duplicate()
		elem.name = "Element" + str(numberElement + 1)
		get_node(pathCurrentMatrix + "/AdditionalRow").add_child(elem)


func create_level(numberLevel, numberElements):
	if numberElements == 0:
		return
	
	var level = HBoxContainer.new()
	level.name = "Level" + str(numberLevel)
	level.alignment = BoxContainer.ALIGNMENT_CENTER
	level.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	level.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	level.set("theme_override_constants/separation", 25)
	get_node(pathTree).add_child(level)
	
	var element = create_line_edit(false)
	for numElement in range(numberElements):
		var elem = element.duplicate()
		elem.name = "Element" + str(numberElements)
		level.add_child(elem)


func recolor_row_matrix(numberRow):
	var numberElement = numberRow * currentMatrix.columns
	
	for numElement in range(currentMatrix.columns):
		if get_node(pathCurrentMatrix + "/Matrix").get_child(numElement + numberElement).get("theme_override_colors/font_uneditable_color") != Color(0.306, 0.906, 0.596):
			get_node(pathCurrentMatrix + "/Matrix").get_child(numElement + numberElement).set("theme_override_colors/font_uneditable_color", Color(0.741, 0.125, 0.106))


func recolor_column_matrix(numberColumn):
	var numberChildren = numberColumn
	
	for numElement in range(currentMatrix.columns):
		if get_node(pathCurrentMatrix + "/Matrix").get_child(numberChildren).get("theme_override_colors/font_uneditable_color") != Color(0.306, 0.906, 0.596):
			get_node(pathCurrentMatrix + "/Matrix").get_child(numberChildren).set("theme_override_colors/font_uneditable_color", Color(0.741, 0.125, 0.106))
		numberChildren += currentMatrix.columns


func recolor_matrix_to_white():
	for numberChildren in range(get_node(pathCurrentMatrix + "/Matrix").get_child_count()):
		if get_node(pathCurrentMatrix + "/Matrix").get_child(numberChildren).get("theme_override_colors/font_uneditable_color") != Color(0.306, 0.906, 0.596):
			get_node(pathCurrentMatrix + "/Matrix").get_child(numberChildren).set("theme_override_colors/font_uneditable_color", Color.WHITE)


func recolor_additional_fields_to_white():
	for numberChildren in range(get_node(pathCurrentMatrix + "/AdditionalColumn").get_child_count()):
		get_node(pathCurrentMatrix + "/AdditionalColumn").get_child(numberChildren).set("theme_override_colors/font_uneditable_color", Color.WHITE)
	
	for numberChildren in range(get_node(pathCurrentMatrix + "/AdditionalRow").get_child_count()):
		get_node(pathCurrentMatrix + "/AdditionalRow").get_child(numberChildren).set("theme_override_colors/font_uneditable_color", Color.WHITE)


func clear_additional_field():
	for numberChildren in range(get_node(pathCurrentMatrix + "/AdditionalColumn").get_child_count()):
		get_node(pathCurrentMatrix + "/AdditionalColumn").get_child(numberChildren).text = ""
	
	for numberChildren in range(get_node(pathCurrentMatrix + "/AdditionalRow").get_child_count()):
		get_node(pathCurrentMatrix + "/AdditionalRow").get_child(numberChildren).text = ""


func realization() -> void:
	var baseMatrix = create_base_matrix(currentMatrix.columns)
	add_elements_in_additional_fields(currentMatrix.columns)
	var phi0 = [0, 0]

	for numRow in range(baseMatrix.size()):
		phi0[0] += baseMatrix[numRow].min()
		get_node(pathCurrentMatrix + "/AdditionalColumn").get_child(numRow).set("theme_override_colors/font_uneditable_color", Color(0.306, 0.906, 0.596))
		get_node(pathCurrentMatrix + "/AdditionalColumn").get_child(numRow).text = str(baseMatrix[numRow].min())
	
	information.text = "Для начала вычислим сумму минимальных элементов каждой строки. У нас эта сумма = %d" % [phi0[0]]
	await buttonNext.pressed
	
	recolor_additional_fields_to_white()
	
	for numColumn in range(baseMatrix.size()):
		var minElementInColumn = search_min_value_in_column(baseMatrix, numColumn)
		phi0[1] += minElementInColumn
		get_node(pathCurrentMatrix + "/AdditionalRow").get_child(numColumn).set("theme_override_colors/font_uneditable_color", Color(0.306, 0.906, 0.596))
		get_node(pathCurrentMatrix + "/AdditionalRow").get_child(numColumn).text = str(minElementInColumn)
	
	information.text = "Далее вычислим сумму минимальных элементов каждого столбца. У нас эта сумма = %d" % [phi0[1]]
	await buttonNext.pressed
	
	recolor_additional_fields_to_white()
	var treeRoot = phi0.min()
	
	if phi0[0] == treeRoot:
		for numberChildren in range(get_node(pathCurrentMatrix + "/AdditionalColumn").get_child_count()):
			get_node(pathCurrentMatrix + "/AdditionalColumn").get_child(numberChildren).set("theme_override_colors/font_uneditable_color",Color(0.306, 0.906, 0.596))
	elif phi0[1] == treeRoot:
		for numberChildren in range(get_node(pathCurrentMatrix + "/AdditionalRow").get_child_count()):
			get_node(pathCurrentMatrix + "/AdditionalRow").get_child(numberChildren).set("theme_override_colors/font_uneditable_color",Color(0.306, 0.906, 0.596))
	
	nextArrow.show()
	create_level(0, 1)
	get_node(pathTree + "/Level0" + "/Element1").set("theme_override_colors/font_uneditable_color", Color(0.306, 0.906, 0.596))
	get_node(pathTree + "/Level0" + "/Element1").text = str(treeRoot)
	
	information.text = "Теперь из двух этих сумм выберем минимальную. У нас это %d. Это будет корень дерева" % [treeRoot]
	await buttonNext.pressed
	
	var numberJobWithMinimumCosts = 0
	var workersJobs = []
	workersJobs.resize(baseMatrix.size())
	
	for numberWorker in range(baseMatrix.size()):
		create_level(numberWorker + 1, currentMatrix.columns - numberWorker)

		if numberWorker == baseMatrix.size() - 1:
			for numberJob in range(workersJobs.size()):
				if numberJob in workersJobs:
					continue
				
				workersJobs[numberWorker] = numberJob
				get_node(pathCurrentMatrix + "/Matrix").get_child(numberWorker * currentMatrix.columns + numberJob).set("theme_override_colors/font_uneditable_color", Color(0.306, 0.906, 0.596))
				
				for numberChildren in range(get_node(pathTree).get_child(numberWorker).get_child_count()):
					if get_node(pathTree).get_child(numberWorker).get_child(numberChildren).get("theme_override_colors/font_uneditable_color") == Color(0.306, 0.906, 0.596):
						get_node(pathTree).get_child(numberWorker + 1).get_child(0).set("theme_override_colors/font_uneditable_color", Color(0.306, 0.906, 0.596))
						get_node(pathTree).get_child(numberWorker + 1).get_child(0).text = get_node(pathTree).get_child(numberWorker).get_child(numberChildren).text
				
				
				information.text = "Остался последний работник, назначаем его на оставшуюся работу %d" % [numberJob + 1]
				await buttonNext.pressed
			break
		
		var costsJobs = []
		costsJobs.resize(baseMatrix.size())
		var minimumJobsCosts = 1_000_000
		
		for numberJob in range(baseMatrix.size()):
			recolor_matrix_to_white()
			recolor_additional_fields_to_white()
			clear_additional_field()
			information.text = "Пытаемся назначить %d работника на %d работу" % [numberWorker + 1, numberJob + 1]
			await buttonNext.pressed
			
			if numberJob in workersJobs:
				information.text = "На эту работу уже назначен другой сотрудник"
				await buttonNext.pressed
				continue
			
			var phi = [0, 0]
			var reducedMatrix = baseMatrix.duplicate(true)
			
			var deleteRows = []
			
			for numberRow in range(reducedMatrix.size()):
				if numberRow <= numberWorker:
					deleteRows.append(numberRow)
					continue
				break
			
			var countDeletedRows = 0
			
			for numberRow in deleteRows:
				reducedMatrix.remove_at(numberRow)
				recolor_row_matrix(numberRow + countDeletedRows)
				
				for numberElement in range(deleteRows.size()):
					deleteRows[numberElement] -= 1
				countDeletedRows += 1
				
				information.text = "Вычёркиваем %d строку" % [numberRow + countDeletedRows]
				await buttonNext.pressed
			
			var deleteColumns = []
			
			for numJob in workersJobs:
				if numJob == null:
					break
				deleteColumns.append(numJob)
			
			deleteColumns.append(numberJob)
			deleteColumns.sort()
			
			var countDeletedColumns = 0
			
			for numberColumn in deleteColumns:
				for numRow in range(reducedMatrix.size()):
					reducedMatrix[numRow].remove_at(numberColumn)
				recolor_column_matrix(numberColumn + countDeletedColumns)
				
				for numberElement in range(deleteColumns.size()):
					deleteColumns[numberElement] -= 1
				countDeletedColumns += 1
				
				information.text = "Вычёркиваем %d столбец" % [numberColumn + countDeletedColumns]
				await buttonNext.pressed
			
			recolor_additional_fields_to_white()
			
			for numberElement in range(deleteRows.size()):
				deleteRows[numberElement] += countDeletedRows
			
			for numRow in range(reducedMatrix.size()):
				phi[0] += reducedMatrix[numRow].min()
				for numberChildren in range(get_node(pathCurrentMatrix + "/AdditionalColumn").get_child_count()):
					if numberChildren in deleteRows:
						continue
					deleteRows.append(numberChildren)
					get_node(pathCurrentMatrix + "/AdditionalColumn").get_child(numberChildren).set("theme_override_colors/font_uneditable_color", Color(0.306, 0.906, 0.596))
					get_node(pathCurrentMatrix + "/AdditionalColumn").get_child(numberChildren).text = str(reducedMatrix[numRow].min())
					break
			
			information.text = "Теперь считаем сумму минимальных элементов каждой строки оставшихся элементов. У нас она равна %d" % [phi[0]]
			await buttonNext.pressed
			
			recolor_additional_fields_to_white()
			
			for numberElement in range(deleteColumns.size()):
				deleteColumns[numberElement] += countDeletedColumns
			
			for numColumn in range(reducedMatrix.size()):
				var minElementInColumn = search_min_value_in_column(reducedMatrix, numColumn)
				phi[1] += minElementInColumn
				for numberChildren in range(get_node(pathCurrentMatrix + "/AdditionalRow").get_child_count()):
					if numberChildren in deleteColumns:
						continue
					deleteColumns.append(numberChildren)
					get_node(pathCurrentMatrix + "/AdditionalRow").get_child(numberChildren).set("theme_override_colors/font_uneditable_color", Color(0.306, 0.906, 0.596))
					get_node(pathCurrentMatrix + "/AdditionalRow").get_child(numberChildren).text = str(minElementInColumn)
					break
			
			information.text = "Теперь считаем сумму минимальных элементов каждого столбца оставшихся элементов. У нас она равна %d" % [phi[1]]
			await buttonNext.pressed
			
			var jobCosts = baseMatrix[numberWorker][numberJob] + phi.min()
			
			for numWorker in range(workersJobs.size()):
				if workersJobs[numWorker] != null:
					jobCosts +=  baseMatrix[numWorker][workersJobs[numWorker]]
			
			costsJobs[numberJob] = jobCosts
			
			var numberChildren = 0
			
			for costsJob in costsJobs:
				if costsJob == null:
					continue
				get_node(pathTree).get_child(numberWorker + 1).get_child(numberChildren).text = str(costsJob)
				numberChildren += 1
			
			information.text = "Cтоимость работы %d для работника %d = %d" % [numberJob + 1, numberWorker + 1, jobCosts]
			
			if jobCosts < minimumJobsCosts:
				minimumJobsCosts = jobCosts
				numberJobWithMinimumCosts = numberJob
			
			await buttonNext.pressed
		
		workersJobs[numberWorker] = numberJobWithMinimumCosts
		
		get_node(pathCurrentMatrix + "/Matrix").get_child(numberWorker * currentMatrix.columns + numberJobWithMinimumCosts).set("theme_override_colors/font_uneditable_color", Color(0.306, 0.906, 0.596))
		
		var deleteElements = []

		for numberElement in range(costsJobs.size()):
			if costsJobs[numberElement] == null:
				deleteElements.append(numberElement)
		
		for element in deleteElements:
			costsJobs.remove_at(element)
			
			for numberElement in range(deleteElements.size()):
				deleteElements[numberElement] -= 1
		
		var minElement = costsJobs[0]
		var numberMinElement = 0
		
		for numberElement in range(costsJobs.size()):
			if costsJobs[numberElement] < minElement:
				minElement = costsJobs[numberElement]
				numberMinElement = numberElement
			
		get_node(pathTree).get_child(numberWorker + 1).get_child(numberMinElement).set("theme_override_colors/font_uneditable_color", Color(0.306, 0.906, 0.596))
		
		recolor_matrix_to_white()
		recolor_additional_fields_to_white()
		clear_additional_field()
		
		information.text = "Работник %d назначен на работу %d" % [numberWorker + 1, numberJobWithMinimumCosts + 1]
		await buttonNext.pressed
	
	var optimalValue = 0
	
	for numWorker in range(workersJobs.size()):
		optimalValue += baseMatrix[numWorker][workersJobs[numWorker]]
	
	information.text = "Оптимальное значение: %d" % [optimalValue]
	buttonNext.hide()



func _on_edit_matrix_size_text_changed(new_text):
	if not new_text.is_valid_int():
		information.text = "Число, пожалуйста..."
		return
	
	if int(new_text) <= 0:
		information.text = "Размерность матрицы %d, серьёзно?" % [int(new_text)]
		return
	
	for children in get_node(pathCurrentMatrix + "/Matrix").get_children():
		get_node(pathCurrentMatrix + "/Matrix").remove_child(children)
		children.queue_free()
	
	currentMatrix.columns = int(new_text)

	add_elements_in_matrix(pow(currentMatrix.columns, 2), true, pathCurrentMatrix + "/Matrix")

	information.text = "Матрица %d x %d создана, ждём ввода значений элементов матрицы..." % [currentMatrix.columns, currentMatrix.columns]
	buttonConfirm.show()


func _on_confirm_pressed():
	for children in get_node(pathCurrentMatrix + "/Matrix").get_children():
		if children.text == "":
			information.text = "Введите значения всех элементов матрицы, пожалуйста"
			return
		elif not children.text.is_valid_int():
			information.text = "Числовые значения, пожалуйста..."
			return
		elif int(children.text) < 0:
			information.text = "Работа, за которую заплатят %d денежных единиц. Прикольно, но у нас такого не будет" % [int(children.text)]
			return
	
	for children in get_node(pathCurrentMatrix + "/Matrix").get_children():
		children.virtual_keyboard_enabled = false
		children.editable = false
		children.focus_mode = FOCUS_NONE
	
	presets.disabled = true
	editMatrixSize.virtual_keyboard_enabled = false
	editMatrixSize.editable = false
	editMatrixSize.focus_mode = FOCUS_NONE
	
	buttonConfirm.hide()
	buttonNext.show()
	realization()


func _on_start_again_pressed():
	get_tree().reload_current_scene()


func _on_presets_item_selected(index):
	var matrix
	
	match index:
		0: matrix = [[2, 4, 1, 3, 3], [1, 5, 4, 1, 2], [3, 5, 2, 2, 4], [1, 4, 3, 1, 4], [3, 2, 5, 3, 5]]
		1: matrix = [[9, 3, 9, 6, 9], [9, 14, 9, 4, 9], [14, 11, 17, 8, 8], [13, 14, 16, 7, 7], [7, 11, 9, 8, 11]]
		2: matrix = [[11, 10, 10, 7, 12], [7, 12, 12, 12, 5], [8, 8, 13, 7, 6], [9, 8, 9, 5, 11], [11, 10, 11, 9, 8]]
		3: matrix = [[1, 7, 1, 3], [1, 6, 4, 6], [17, 1, 5, 1], [1, 6, 10, 4]]
		4: matrix = [[9, 2, 7, 8], [6, 4, 3, 7], [5, 8, 1, 8], [7, 6, 9, 4]]
	
	editMatrixSize.text = str(matrix.size())
	editMatrixSize.emit_signal("text_changed", str(matrix.size()))
	
	var numberChildren = 0
	
	for numRow in range(matrix.size()):
		for numColumn in range(matrix.size()):
			get_node(pathCurrentMatrix + "/Matrix").get_child(numberChildren).text = str(matrix[numRow][numColumn])
			numberChildren += 1
	
	information.text = "Заготовка %d успешно загружена" % [index + 1]


func _on_back_select_algorithm_pressed():
	get_tree().change_scene_to_file("res://AssignmentProblem/AssignmentProblem.tscn")
