extends Control

@onready var currentMatrix = $Margins/HungarianAlgorithm/ScrollMatrix/Matrices/CurrentMatrix/Matrix
@onready var nextMatrix = $Margins/HungarianAlgorithm/ScrollMatrix/Matrices/NextMatrix/Matrix

@onready var arrowNext = $"Margins/HungarianAlgorithm/ScrollMatrix/Matrices/----->"
@onready var editMatrixSize = $Margins/HungarianAlgorithm/MatrixSize/EditMatrixSize
@onready var presets = $Margins/HungarianAlgorithm/MatrixSize/Presets

@onready var buttonConfirm = $Margins/HungarianAlgorithm/Buttons/MarginsButtons/Confirm
@onready var buttonNext = $Margins/HungarianAlgorithm/Buttons/MarginsButtons/Next

@onready var information = $Margins/HungarianAlgorithm/Information

var pathCurrentMatrix = "Margins/HungarianAlgorithm/ScrollMatrix/Matrices/CurrentMatrix"
var pathNextMatrix = "Margins/HungarianAlgorithm/ScrollMatrix/Matrices/NextMatrix"



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


func create_marked_matrix(matrixSize) -> Array:
	var resultMatrix = []
	resultMatrix.resize(matrixSize)
	
	for numRow in range(matrixSize):
		resultMatrix[numRow] = []
		resultMatrix[numRow].resize(matrixSize)

	for numRow in range(matrixSize):
		for numColumn in range(matrixSize):
			resultMatrix[numRow][numColumn] = ""
	
	return resultMatrix


func search_min_value_in_column(matrix, numberColumn) -> int:
	var minValue = matrix[0][numberColumn]
	
	for numRow in range(matrix.size()):
		if matrix[numRow][numberColumn] < minValue:
			minValue = matrix[numRow][numberColumn]
	
	return minValue


func reduce_matrix(matrix) -> Array:
	var resultMatrix = matrix.duplicate(true)
	
	#вычитаем из столбцов
	for numColumn in range(resultMatrix.size()):
		var minValueInColumn = search_min_value_in_column(resultMatrix, numColumn)
		for numRow in range(resultMatrix.size()):
			resultMatrix[numRow][numColumn] -= minValueInColumn
	
	#вычитаем из строк
	for numRow in range(resultMatrix.size()):
		var minValueInRow = resultMatrix[numRow].min()
		for numColumn in range(resultMatrix[numRow].size()):
			resultMatrix[numRow][numColumn] -= minValueInRow
	
	return resultMatrix


func mark_zeros(matrix, markedMatrix) -> void:
	for numColumn in range(matrix.size()):
		for numRow in range(matrix.size()):
			if matrix[numRow][numColumn] == 0 and not "*" in markedMatrix[numRow]:
				markedMatrix[numRow][numColumn] = "*"
				markedMatrix[markedMatrix.size() - 1][numColumn] = "+"
				break


func check_marked_zero_in_each_row(markedMatrix) -> bool:
	for numColumn in range(markedMatrix.size() - 1):
		if markedMatrix[markedMatrix.size() - 1][numColumn] != "+":
			return false
	return true


func try_find_unmarked_zero(matrix, markedMatrix, markedZero) -> bool:
	update_values_matrix(matrix, markedMatrix, pathCurrentMatrix)
	update_values_additional_fields_matrix(markedMatrix, pathCurrentMatrix)
	
	for numColumn in range(matrix.size()):
		if markedMatrix[markedMatrix.size() - 1][numColumn] == "+":
			continue
		for numRow in range(matrix.size()):
			if markedMatrix[numRow][markedMatrix[numRow].size() - 1] == "+":
				continue
			if matrix[numRow][numColumn] == 0:
				markedMatrix[numRow][numColumn] = "/"
				markedZero[0] = numRow
				markedZero[1] = numColumn
				update_values_matrix(matrix, markedMatrix, pathNextMatrix)
				update_values_additional_fields_matrix(markedMatrix, pathNextMatrix)
				return true
	return false


func get_min_value_from_unmarked_values(matrix, markedMatrix) -> int:
	var minValue = 9_223_372_036_854_775_807
	
	for numColumn in range(matrix.size()):
		if markedMatrix[markedMatrix.size() - 1][numColumn] == "+":
			continue
		for numRow in range(matrix.size()):
			if markedMatrix[numRow][markedMatrix[numRow].size() - 1] == "+":
				continue
			if matrix[numRow][numColumn] < minValue:
				minValue = matrix[numRow][numColumn]
	
	return minValue


func create_zeros(matrix, markedMatrix) -> void:
	update_values_matrix(matrix, markedMatrix, pathCurrentMatrix)
	update_values_additional_fields_matrix(markedMatrix, pathCurrentMatrix)
	
	var minValue = get_min_value_from_unmarked_values(matrix, markedMatrix)
	
	for numColumn in range(matrix.size()):
		if markedMatrix[markedMatrix.size() - 1][numColumn] == "+":
			continue
		for numRow in range(matrix.size()):
			if markedMatrix[numRow][markedMatrix[numRow].size() - 1] == "+":
				continue
			matrix[numRow][numColumn] -= minValue
	
	update_values_matrix(matrix, markedMatrix, pathNextMatrix)
	update_values_additional_fields_matrix(markedMatrix, pathNextMatrix)


func try_find_marked_zero_in_row(matrix, markedMatrix, markedZero) -> bool:
	update_values_matrix(matrix, markedMatrix, pathCurrentMatrix)
	update_values_additional_fields_matrix(markedMatrix, pathCurrentMatrix)
	
	var rowMarkedZero = markedZero[0]
	
	for numColumn in range(markedMatrix.size() - 1):
		if markedMatrix[rowMarkedZero][numColumn] == "*":
			markedMatrix[rowMarkedZero][markedMatrix[rowMarkedZero].size() - 1] = "+"
			markedMatrix[markedMatrix.size() - 1][numColumn] = ""
			update_values_matrix(matrix, markedMatrix, pathNextMatrix)
			update_values_additional_fields_matrix(markedMatrix, pathNextMatrix)
			return true
	return false


func l_chain(matrix, markedMatrix, markedZero) -> void:
	update_values_matrix(matrix, markedMatrix, pathCurrentMatrix)
	update_values_additional_fields_matrix(markedMatrix, pathCurrentMatrix)

	var rowMarkedZero = markedZero[0]
	var columnMarkedZero = markedZero[1]
	markedMatrix[rowMarkedZero][columnMarkedZero] = "*"
	

	while(true):
		for numRow in range(markedMatrix.size() - 1):
			if numRow == rowMarkedZero:
				continue
			if markedMatrix[numRow][columnMarkedZero] == "*":
				markedMatrix[numRow][columnMarkedZero] = "/"
				rowMarkedZero = numRow
				break
		
		if markedMatrix[rowMarkedZero][columnMarkedZero] == "*":
			break
		
		for numColumn in range(markedMatrix.size() - 1):
			if numColumn == columnMarkedZero:
				continue
			if markedMatrix[rowMarkedZero][numColumn] == "/":
				markedMatrix[rowMarkedZero][numColumn] = "*"
				columnMarkedZero = numColumn
				break
		
		if markedMatrix[rowMarkedZero][columnMarkedZero] == "/":
			break
	
	update_values_matrix(matrix, markedMatrix, pathNextMatrix)


func mark_plus(markedMatrix) -> void:
	for numColumn in range(markedMatrix.size() - 1):
		for numRow in range(markedMatrix.size() - 1):
			if markedMatrix[numRow][numColumn] == "*":
				markedMatrix[markedMatrix.size() - 1][numColumn] = "+"
				break
	
	for numRow in range(markedMatrix.size() - 1):
		markedMatrix[numRow][markedMatrix[numRow].size() - 1] = ""
	
	update_values_additional_fields_matrix(markedMatrix, pathNextMatrix)


func get_optimal_matrix(markedMatrix) -> Array:
	var resultMatrix = []
	resultMatrix.resize(markedMatrix.size() - 1)
	
	for numRow in range(resultMatrix.size()):
		resultMatrix[numRow] = []
		resultMatrix[numRow].resize(markedMatrix.size() - 1)
	
	for numColumn in range(resultMatrix.size()):
		for numRow in range(resultMatrix.size()):
			if markedMatrix[numRow][numColumn] == "*":
				resultMatrix[numRow][numColumn] = 1
				continue
			resultMatrix[numRow][numColumn] = 0
	
	return resultMatrix


func get_optimal_value(baseMatrix, optimalMatrix) -> int:
	var optimalValue = 0
	
	for numColumn in range(optimalMatrix.size()):
		for numRow in range(optimalMatrix.size()):
			if optimalMatrix[numRow][numColumn] == 1:
				optimalValue += baseMatrix[numRow][numColumn]
				break
	
	return optimalValue


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


func update_values_matrix(matrixWithValues, markedMatrix, matrixForUpdate):
	var numberChildren = 0
	
	for numRow in range(matrixWithValues.size()):
		for numColumn in range(matrixWithValues.size()):
			if (str(matrixWithValues[numRow][numColumn]) + str(markedMatrix[numRow][numColumn])) == get_node(matrixForUpdate + "/Matrix").get_child(numberChildren).text:
				get_node(matrixForUpdate + "/Matrix").get_child(numberChildren).set("theme_override_colors/font_uneditable_color", Color.WHITE)
				numberChildren += 1
				continue
			
			get_node(matrixForUpdate + "/Matrix").get_child(numberChildren).text = str(matrixWithValues[numRow][numColumn]) + str(markedMatrix[numRow][numColumn])
			
			if "NextMatrix" in matrixForUpdate:
				get_node(matrixForUpdate + "/Matrix").get_child(numberChildren).set("theme_override_colors/font_uneditable_color", Color(0.306, 0.906, 0.596))
				numberChildren += 1
				continue
			
			get_node(matrixForUpdate + "/Matrix").get_child(numberChildren).set("theme_override_colors/font_uneditable_color", Color.WHITE)
			numberChildren += 1


func update_values_additional_fields_matrix(markedMatrix, matrixForUpdate):
	if get_node(matrixForUpdate + "/AdditionalColumn").get_child_count() == 0:
		add_elements_in_matrix(currentMatrix.columns, false, (matrixForUpdate + "/AdditionalColumn"))
		add_elements_in_matrix(currentMatrix.columns, false, (matrixForUpdate + "/AdditionalRow"))
	
	for numRow in range(markedMatrix.size() - 1):
		if str(markedMatrix[numRow][markedMatrix[numRow].size() - 1]) == get_node(matrixForUpdate + "/AdditionalColumn").get_child(numRow).text:
			get_node(matrixForUpdate + "/AdditionalColumn").get_child(numRow).set("theme_override_colors/font_uneditable_color", Color.WHITE)
			continue
		
		get_node(matrixForUpdate + "/AdditionalColumn").get_child(numRow).text = str(markedMatrix[numRow][markedMatrix[numRow].size() - 1])
		
		if "NextMatrix" in matrixForUpdate:
			get_node(matrixForUpdate + "/AdditionalColumn").get_child(numRow).set("theme_override_colors/font_uneditable_color", Color(0.306, 0.906, 0.596))
			continue
		get_node(matrixForUpdate + "/AdditionalColumn").get_child(numRow).set("theme_override_colors/font_uneditable_color", Color.WHITE)
	
	
	for numColumn in range(markedMatrix[0].size() - 1):
		if str(markedMatrix[markedMatrix.size() - 1][numColumn]) == get_node(matrixForUpdate + "/AdditionalRow").get_child(numColumn).text:
			get_node(matrixForUpdate + "/AdditionalRow").get_child(numColumn).set("theme_override_colors/font_uneditable_color", Color.WHITE)
			continue
		
		get_node(matrixForUpdate + "/AdditionalRow").get_child(numColumn).text = str(markedMatrix[markedMatrix.size() - 1][numColumn])
		
		if "NextMatrix" in matrixForUpdate:
			get_node(matrixForUpdate + "/AdditionalRow").get_child(numColumn).set("theme_override_colors/font_uneditable_color", Color(0.306, 0.906, 0.596))
			continue
		get_node(matrixForUpdate + "/AdditionalRow").get_child(numColumn).set("theme_override_colors/font_uneditable_color", Color.WHITE)


func output_optimal_matrix(optimalMatrix, matrixForOutput):
	var numberChildren = 0
	
	for numRow in range(optimalMatrix.size()):
		for numColumn in range(optimalMatrix.size()):
			get_node(matrixForOutput + "/Matrix").get_child(numberChildren).text = str(optimalMatrix[numRow][numColumn])
			
			if optimalMatrix[numRow][numColumn] == 1:
				get_node(matrixForOutput + "/Matrix").get_child(numberChildren).set("theme_override_colors/font_uneditable_color", Color(0.306, 0.906, 0.596))
				numberChildren += 1
				continue
			
			get_node(matrixForOutput + "/Matrix").get_child(numberChildren).set("theme_override_colors/font_uneditable_color", Color.WHITE)
			numberChildren += 1


func output_base_matrix(baseMatrix, optimalMatrix, matrixForOutput):
	var numberChildren = 0
	
	for numRow in range(baseMatrix.size()):
		for numColumn in range(baseMatrix.size()):
			get_node(matrixForOutput + "/Matrix").get_child(numberChildren).text = str(baseMatrix[numRow][numColumn])
			
			if optimalMatrix[numRow][numColumn] == 1:
				get_node(matrixForOutput + "/Matrix").get_child(numberChildren).set("theme_override_colors/font_uneditable_color", Color(0.306, 0.906, 0.596))
				numberChildren += 1
				continue
			
			get_node(matrixForOutput + "/Matrix").get_child(numberChildren).set("theme_override_colors/font_uneditable_color", Color.WHITE)
			numberChildren += 1


func realization() -> void:
	var baseMatrix = create_base_matrix(currentMatrix.columns)
	var markedMatrix = create_marked_matrix(currentMatrix.columns + 1)

	information.text = "Итак, для начала вычтем из строк и столбцов минимальные элементы соотвествующих строк и столбцов"
	
	var reducedMatrix = reduce_matrix(baseMatrix)
	arrowNext.show()
	
	add_elements_in_matrix(pow(currentMatrix.columns, 2), false, "Margins/HungarianAlgorithm/ScrollMatrix/Matrices/NextMatrix/Matrix")
	update_values_matrix(reducedMatrix, markedMatrix, pathNextMatrix)
	
	await buttonNext.pressed
	
	information.text = "Теперь выделим по одному нулю в каждом столбце. При этом в каждой строке должен быть только один такой выделенный ноль"
	
	update_values_matrix(reducedMatrix, markedMatrix, pathCurrentMatrix)
	mark_zeros(reducedMatrix, markedMatrix)
	update_values_matrix(reducedMatrix, markedMatrix, pathNextMatrix)
	
	await buttonNext.pressed
	
	information.text = "Пометим отмеченные столбцы"
	
	update_values_additional_fields_matrix(markedMatrix, pathNextMatrix)
	
	await buttonNext.pressed
	
	var markedZero = [0, 0]
	var numberCicles = 0
	
	while(true):
		numberCicles += 1
		if check_marked_zero_in_each_row(markedMatrix):
			information.text = "В каждом столбце есть выделенный ноль, победа!"
			await buttonNext.pressed
			break
		
		information.text = "Не во всех столбцах есть выделенные нули. Пытаемся найти невыделенный ноль среди неотмеченных столбцов и строк"
		await buttonNext.pressed
		
		if not try_find_unmarked_zero(reducedMatrix, markedMatrix, markedZero):
			information.text = "Такого невыделенного нуля не нашли, вычитаем из невыделенных элементов минимальный"
			create_zeros(reducedMatrix, markedMatrix)
			await buttonNext.pressed
			continue
		
		information.text = "Такой невыделенный ноль найден. Пытаемся найти выделенный ноль в строке с этим невыделенным нулём"
		await buttonNext.pressed
		
		if try_find_marked_zero_in_row(reducedMatrix, markedMatrix, markedZero):
			information.text = "Такой выделенный ноль найден. Переносим отметку из столбца в строку"
			await buttonNext.pressed
			continue
		
		information.text = "Такого нуля не найдено, приступаем к L-цепочке"
		l_chain(reducedMatrix, markedMatrix, markedZero)
		await buttonNext.pressed
		information.text = "По новой пометим столбцы с выделенными нулями"
		mark_plus(markedMatrix)
		await buttonNext.pressed
	
	information.text = "Полученная оптимальная матрица"
	update_values_matrix(reducedMatrix, markedMatrix, pathCurrentMatrix)
	update_values_additional_fields_matrix(markedMatrix, pathCurrentMatrix)
	
	var optimalMatrix = get_optimal_matrix(markedMatrix)
	
	output_optimal_matrix(optimalMatrix, pathNextMatrix)
	update_values_additional_fields_matrix(markedMatrix, pathNextMatrix)
	
	await buttonNext.pressed
	
	output_optimal_matrix(optimalMatrix, pathCurrentMatrix)
	update_values_additional_fields_matrix(markedMatrix, pathCurrentMatrix)
	
	output_base_matrix(baseMatrix, optimalMatrix, pathNextMatrix)
	update_values_additional_fields_matrix(markedMatrix, pathNextMatrix)
	
	var optimalValue = get_optimal_value(baseMatrix, optimalMatrix)
	information.text = "Оптимальная сумма = %d. Количество пройденных циклов: %d" % [optimalValue, numberCicles]
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
	nextMatrix.columns = int(new_text)

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
	
	editMatrixSize.virtual_keyboard_enabled = false
	editMatrixSize.editable = false
	editMatrixSize.focus_mode = FOCUS_NONE
	
	presets.disabled = true
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
