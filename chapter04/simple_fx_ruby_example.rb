require 'fox16'

include Fox

myApp = FXApp.new

mainWindow=FXMainWindow.new(myApp, "Simple FXRuby Control Demo", 
                                   :padding =>10, :vSpacing=>10)

my_first_button= FXButton.new(mainWindow, 'Example Button Control')
my_first_button.connect(SEL_COMMAND) do 
  my_first_button.text="In a real-life situation, this would do something."
end

FXTextField.new(mainWindow, 30).text = 'Example Text Control'

FXRadioButton.new(mainWindow, "Example Radio Control")
FXCheckButton.new(mainWindow, "Example Check Control")

myApp.create

mainWindow.show( PLACEMENT_SCREEN )

myApp.run

