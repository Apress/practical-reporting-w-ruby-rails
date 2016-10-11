require 'pdf/writer'

pdf_document = PDF::Writer.new

pdf_document.select_font "Times-Roman"
pdf_document.text "Hello world!"
pdf_document.save_as "out.pdf"

