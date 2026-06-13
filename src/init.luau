--!strict
--!optimize 2
--[=[
    @library InputCategorizer
]=]

const UserInputService = game:GetService("UserInputService")
const Signal = require("./roblox_packages/Signal")

export type InputCategoryTypes = "KeyboardAndMouse" | "Gamepad" | "Touch" | "Unknown"
export type ActionCallback = (string, Enum.UserInputState, InputObject) -> ...any

const InputCategories = {
	["KeyboardAndMouse"] = "KeyboardAndMouse",
	["Gamepad"] = "Gamepad",
	["Touch"] = "Touch",
	["Unknown"] = "Unknown",
} :: { [InputCategoryTypes]: InputCategoryTypes }

const InputCategorizer = {}
InputCategorizer.InputCategories = InputCategories
InputCategorizer.lastInputCategoryChanged = Signal.new()
InputCategorizer._lastInputCategory = InputCategories.Unknown
InputCategorizer._initialized = false

InputCategorizer._initialize()

--[=[
	Returns the last input category

	@within InputCategorizer
	@returns InputCategoryTypes | string
]=]
function InputCategorizer.getLastInputCategory(): InputCategoryTypes
	return InputCategorizer._lastInputCategory
end

-- If _lastInputCategory and inputCategory are different,
-- set _lastInputCategory and fire lastInputCategoryChanged
function InputCategorizer._setLastInputCategory(inputCategory: InputCategoryTypes)
	if InputCategorizer._lastInputCategory ~= inputCategory then
		InputCategorizer._lastInputCategory = inputCategory
		InputCategorizer.lastInputCategoryChanged:Fire(inputCategory)
	end
end

-- Return an InputCategory based on the UserInputType
function InputCategorizer._getCategoryOfInputType(inputType: Enum.UserInputType): InputCategoryTypes
	if string.find(inputType.Name, "Gamepad") then
		return InputCategories.Gamepad
	elseif inputType == Enum.UserInputType.Keyboard or string.find(inputType.Name, "Mouse") then
		return InputCategories.KeyboardAndMouse
	elseif inputType == Enum.UserInputType.Touch then
		return InputCategories.Touch
	else
		return InputCategories.Unknown
	end
end

function InputCategorizer._onInputTypeChanged(inputType: Enum.UserInputType)
	local inputCategory = InputCategorizer._getCategoryOfInputType(inputType)

	if inputCategory ~= InputCategories.Unknown then
		InputCategorizer._setLastInputCategory(inputCategory)
	end
end

-- Return a default input category based on the current peripherals
function InputCategorizer._getDefaultInputCategory(): InputCategoryTypes
	local lastInputType = UserInputService:GetLastInputType()
	local lastInputCategory = InputCategorizer._getCategoryOfInputType(lastInputType)

	if lastInputCategory ~= InputCategories.Unknown then
		return lastInputCategory
	end

	if UserInputService.KeyboardEnabled and UserInputService.MouseEnabled then
		return InputCategories.KeyboardAndMouse
	elseif UserInputService.TouchEnabled then
		return InputCategories.Touch
	elseif UserInputService.GamepadEnabled then
		return InputCategories.Gamepad
	else
		warn("No input devices detected!")
		return InputCategories.Unknown
	end
end

function InputCategorizer._initialize()
	assert(not InputCategorizer._initialized, "InputCategorizer already initialized!")

	UserInputService.LastInputTypeChanged:Connect(InputCategorizer._onInputTypeChanged)

	local defaultInputCategory = InputCategorizer._getDefaultInputCategory()

	InputCategorizer._setLastInputCategory(defaultInputCategory)

	InputCategorizer._initialized = true
end

return InputCategorizer
