# Implementation Plan: PDF-from-Code Generator

Transitioning from PDF template modification to a programmatic "PDF-from-Code" engine using `syncfusion_flutter_pdf`.

## Phase 1: Research & Component Foundation
Establish the precise visual parameters and create the basic building blocks for the new generator.

- [x] Task: Identify precise HEX colors, font weights, and dimensions (margins, column widths) from the original YONIK PDF. 6c9b5a1
- [x] Task: Create a base `InvoiceTheme` class to hold branding constants (e.g., brand blue, text styles). 72bf812
    - [x] Write unit tests for `InvoiceTheme` default values.
    - [x] Implement `InvoiceTheme`.
- [~] Task: Implement programmatic drawing for the header and footer blue bars.
    - [ ] Write unit tests to verify bar positioning and color.
    - [ ] Implement drawing logic using `PdfGraphics`.
- [ ] Task: Conductor - User Manual Verification 'Research & Component Foundation' (Protocol in workflow.md)

## Phase 2: Drawing Engine Components (TDD)
Implement the core layout sections as isolated, testable components.

- [ ] Task: Implement the `InvoiceHeader` component (Logo, "ב"ה", Company Address, Date/No labels).
    - [ ] Write unit tests for header text placement and alignment.
    - [ ] Implement `InvoiceHeader` drawing logic.
- [ ] Task: Implement the `InvoiceCustomerInfo` component (Bill To / Ship To headers and data).
    - [ ] Write unit tests for customer info section layout.
    - [ ] Implement `InvoiceCustomerInfo` drawing logic.
- [ ] Task: Implement the `InvoiceItemsTable` component (Fixed rows, headers: Description, Qty, Price, Total).
    - [ ] Write unit tests for table grid drawing and text overflow handling.
    - [ ] Implement `InvoiceItemsTable` drawing logic.
- [ ] Task: Implement the `InvoiceTotals` component (Subtotal, VAT, Balance Due).
    - [ ] Write unit tests for totals alignment and labeling.
    - [ ] Implement `InvoiceTotals` drawing logic.
- [ ] Task: Conductor - User Manual Verification 'Drawing Engine Components' (Protocol in workflow.md)

## Phase 3: Generator Assembly & Integration
Assemble the components into a functional service and replace the legacy injection logic.

- [ ] Task: Create the `PdfCodeGenerator` service to orchestrate the drawing components.
    - [ ] Write integration tests for the full PDF generation flow.
    - [ ] Implement `PdfCodeGenerator`.
- [ ] Task: Swap the current template-based PDF service for the new `PdfCodeGenerator` in the application logic.
- [ ] Task: Verify that the Real-time Preview correctly renders the output from the new code-based generator.
- [ ] Task: Conductor - User Manual Verification 'Generator Assembly & Integration' (Protocol in workflow.md)

## Phase 4: Validation & Cleanup
Ensure pixel-perfection and remove legacy artifacts.

- [ ] Task: Perform a side-by-side visual audit of the generated PDF vs. the original template.
- [ ] Task: Verify that file naming and history saving still work as expected.
- [ ] Task: Remove the legacy `invoice_template.pdf` asset and related code.
- [ ] Task: Conductor - User Manual Verification 'Final Validation & Cleanup' (Protocol in workflow.md)
