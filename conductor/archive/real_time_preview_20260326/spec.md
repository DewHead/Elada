# Specification - Real-time PDF Preview

## Overview
This track focuses on enhancing the user experience by providing a live visual preview of the invoice as fields are being edited. This replaces the "Generate and Check" cycle with immediate feedback.

## User Stories
- **As a freelancer,** I want to see a preview of my invoice as I type so that I can catch errors before generating the final PDF.
- **As a freelancer,** I want the preview to be responsive so that I can easily see the changes on both desktop and mobile devices.

## Functional Requirements
- **Integrated PDF Viewer:** Add a PDF viewing component to the generator screen.
- **Dynamic Preview Generation:** Update the preview PDF in memory whenever the user pauses typing (debounce logic).
- **Responsive Layout:** 
    - Desktop: Side-by-side view (Inputs on left, Preview on right).
    - Mobile: Toggleable view or Modal preview.
- **Preview Optimization:** Ensure preview generation is fast and doesn't block the UI thread.

## Technical Constraints
- **PDF Viewer Library:** `syncfusion_flutter_pdfviewer` (already using syncfusion for PDF manipulation).
- **Performance:** Use `compute()` or `Isolates` for background PDF generation if necessary.
- **State Management:** Update `InvoiceProvider` to handle preview state.
