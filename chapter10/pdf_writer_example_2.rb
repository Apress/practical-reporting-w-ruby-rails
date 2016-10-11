require 'pdf/writer'

options = {}

require 'PDF/SimpleTable'
pdf_document =   PDF::Writer.new
table= PDF::SimpleTable.new
table.data = [['Hello', 'world',], [1,2]]
table.render_on(pdf_document)

pdf_document.save_as("test.pdf")
