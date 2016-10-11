require 'win32ole'

word_app = WIN32OLE.new('Word.Application')
word_app.visible = true
word_document = word_app.Documents.Open(File.join(Dir.pwd,"resignation_letter_template.doc"))
current_selection = word_app.selection
find_object = current_selection.Find
find_object.execute('%%BOSS%%', :replaceWith=>'jon jonnerson')

#Function Execute([FindText], [MatchCase], [MatchWholeWord], [MatchWildcards], [MatchSoundsLike], [MatchAllWordForms], [Forward], [Wrap], [Format], [ReplaceWith], [Replace], [MatchKashida], [MatchDiacritics], [MatchAlefHamza], [MatchControl]) As Boolean

#word_document.SaveAs 'resignation_letter.doc' 
#word_app.PrintOut

