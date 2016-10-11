require "spreadsheet/excel"
include Spreadsheet

workbook = Excel.new("test.xls")
worksheet = workbook.add_worksheet

worksheet.write(0, 0, 'Hello, world!')
workbook.close

