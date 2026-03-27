# Track Specification: PDF-from-Code Generator

## Overview
This track involves transitioning the invoice generation process from modifying an existing PDF template to programmatically generating the PDF from code. This "PDF-from-Code" approach will replace the current `syncfusion_flutter_pdf` field injection method with a more flexible, maintainable, and visually precise drawing-based engine.

## Functional Requirements
- **Visual Replication:** Recreate the exact layout of the provided "YONIK KOSHER LIFESTYLE" PDF template using the `syncfusion_flutter_pdf` drawing API.
- **Visual Fidelity Source:** The provided `Copy of Invoice-YONIK KOSHER LIFESTYLE.pdf` is the absolute source of truth for:
    - **Typography:** Font weights, sizes, and colors (notably the blue brand color).
    - **Layout:** Precise positioning of the "ב"ה", "INVOICE", and "YONIK KOSHER LIFESTYLE LTD" headers.
    - **Structural Elements:** The blue bars at the top and bottom, table borders, and horizontal separators.
- **Component-Based Architecture:** Deconstruct the invoice into reusable Dart-based layout components:
    - `InvoiceHeader`: Company logo/name, address, date, and invoice number.
    - `InvoiceCustomerInfo`: Bill To and Ship To sections.
    - `InvoiceItemsTable`: The 4-column table (Description, Qty, Unit Price, Total) with fixed rows.
    - `InvoiceTotals`: Subtotal, Discount, VAT, Shipping, and Balance Due.
- **Branding Integration:** 
    - Use embedded high-resolution assets if available, or recreate precisely using code.
    - Programmatically draw all structural elements (lines, boxes, headers) using `syncfusion`'s drawing commands.
- **Data Injection:** Map existing invoice data (Description, Total, Balance Due, Invoice Date, Invoice Number) into the new drawing-based generator.
- **Output Compatibility:** Ensure the generated PDF maintains high visual fidelity and is compatible with existing export naming and history features.

## Non-Functional Requirements
- **Pixel Perfection:** The generated PDF must be indistinguishable from the original template in terms of layout, typography, and spacing.
- **Performance:** PDF generation should be fast enough to support the real-time preview feature without noticeable lag.
- **Maintainability:** The code-based layout should be easier to update than editing a PDF template.

## Acceptance Criteria
- [ ] A new PDF generation engine is implemented using `syncfusion_flutter_pdf` drawing commands.
- [ ] The generated PDF visually matches the provided "YONIK KOSHER LIFESTYLE" template exactly, including the blue branding elements.
- [ ] All text elements (including "ב"ה") are sharp and correctly positioned according to the original template.
- [ ] The generator correctly handles the current set of invoice fields.
- [ ] The implementation uses a component-based structure in Dart.
- [ ] Real-time preview continues to work correctly with the new engine.

## Out of Scope
- Implementing a fully dynamic, multi-page layout engine in this initial phase.
- Changing the existing UI/UX for data entry.
