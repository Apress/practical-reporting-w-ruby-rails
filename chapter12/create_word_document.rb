require 'win32ole'

word_app = WIN32OLE.new('Word.Application')
word_app.visible = true
word_document = word_app.Documents.add
current_selection = word_app.selection
current_selection.TypeText "Dear Mr Executive, \n" 
current_selection.TypeText "I hereby resign my post as chief programmer. " 
current_selection.TypeText "\n\n" 
current_selection.TypeText "Sincerely,\n" 
current_selection.TypeText "Mr. T. Tom\n" 

word_document.SaveAs 'resignation_letter.doc' 
word_app.PrintOut

