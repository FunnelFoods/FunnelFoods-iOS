# Funnel-iOS

Clone the repository and open the ```.xcworkspace``` file.

- Test a receipt by going to ```Assets.xcassets``` and dragging in a receipt JPG to test, make sure to name it ```test_receipt```.

## Important file locations

- Tesseract: ```Logic/OCR.swift```
- Receipt parsing from string: ```Logic/ReceiptParser.swift```

## Todo:

- Enable cancel button when receipt is being scanned
- Nice ingredient adding UI
- Less janky volume button capture
- Amount parsing
- Login and save to internet, also handle when that is not available
- Recipe suggestion lazy loading UI
