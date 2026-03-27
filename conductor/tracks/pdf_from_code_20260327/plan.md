# Implementation Plan: PDF-from-Code Generator

Transitioning from PDF template modification to a programmatic "PDF-from-Code" engine using `syncfusion_flutter_pdf`.

## Phase 1: Research & Component Foundation [checkpoint: 39dbdce]
Establish the precise visual parameters and create the basic building blocks for the new generator.

- [x] Task: Identify precise HEX colors, font weights, and dimensions (margins, column widths) from the original YONIK PDF. 6c9b5a1
- [x] Task: Create a base `InvoiceTheme` class to hold branding constants (e.g., brand blue, text styles). 72bf812
    - [x] Write unit tests for `InvoiceTheme` default values.
    - [x] Implement `InvoiceTheme`.
- [x] Task: Implement programmatic drawing for the header and footer blue bars. 3823a48
    - [x] Write unit tests to verify bar positioning and color.
    - [x] Implement drawing logic using `PdfGraphics`.
- [x] Task: Conductor - User Manual Verification 'Research & Component Foundation' (Protocol in workflow.md) 39dbdce

## Phase 2: Drawing Engine Components (TDD) [checkpoint: 3eefa27]
Implement the core layout sections as isolated, testable components.

- [x] Task: Implement the `InvoiceHeader` component (Logo, "ב"ה", Company Address, Date/No labels). 51b0911
    - [x] Write unit tests for header text placement and alignment.
    - [x] Implement `InvoiceHeader` drawing logic.
- [x] Task: Implement the `InvoiceCustomerInfo` component (Bill To / Ship To headers and data). 70391a4
    - [x] Write unit tests for customer info section layout.
    - [x] Implement `InvoiceCustomerInfo` drawing logic.
- [x] Task: Implement the `InvoiceItemsTable` component (Fixed rows, headers: Description, Qty, Price, Total). 15b927a
    - [x] Write unit tests for table grid drawing and text overflow handling.
    - [x] Implement `InvoiceItemsTable` drawing logic.
- [x] Task: Implement the `InvoiceTotals` component (Subtotal, VAT, Balance Due). 5b4fdcf
    - [x] Write unit tests for totals alignment and labeling.
    - [x] Implement `InvoiceTotals` drawing logic.
- [x] Task: Conductor - User Manual Verification 'Drawing Engine Components' (Protocol in workflow.md) 3eefa27

## Phase 3: Generator Assembly & Integration
Assemble the components into a functional service and replace the legacy injection logic.

- [x] Task: Create the `PdfCodeGenerator` service to orchestrate the drawing components. 4a7a8ed
    - [x] Write integration tests for the full PDF generation flow.
    - [x] Implement `PdfCodeGenerator`.
- [x] Task: Swap the current template-based PDF service for the new `PdfCodeGenerator` in the application logic. 81f7fd0
- [ ] Task: Verify that the Real-time Preview correctly renders the output from the new code-based generator.
- [ ] Task: Conductor - User Manual Verification 'Generator Assembly & Integration' (Protocol in workflow.md)

## Phase 4: Validation & Cleanup
Ensure pixel-perfection and remove legacy artifacts.

- [ ] Task: Perform a side-by-side visual audit of the generated PDF vs. the original template.
- [ ] Task: Verify that file naming and history saving still work as expected.
- [ ] Task: Remove the legacy `invoice_template.pdf` asset and related code.
- [ ] Task: Conductor - User Manual Verification 'Final Validation & Cleanup' (Protocol in workflow.md)
