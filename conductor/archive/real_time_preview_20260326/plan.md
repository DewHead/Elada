# Implementation Plan - Real-time PDF Preview

This plan follows a TDD approach as defined in the project workflow.

## Phase 1: Research & Setup

- [x] Task: Research and add `syncfusion_flutter_pdfviewer` dependency (938fd7a)
- [x] Task: Evaluate performance of in-memory PDF generation for previews (Confirmed architecture supports Uint8List) (938fd7a)

## Phase 2: Preview Logic Implementation

- [x] Task: Update `PdfService` to return `Uint8List` for in-memory previews (Already supports Uint8List) (938fd7a)
- [x] Task: Implement debounced preview updates in `InvoiceProvider` (5954bff)
- [x] Task: Write unit tests for the updated `InvoiceProvider` and `PdfService` (5954bff)

## Phase 3: UI Integration

- [x] Task: Create `InvoicePreview` widget using `SfPdfViewer.memory` (df152b3)
- [x] Task: Implement responsive layout (Side-by-side for desktop, Toggle for mobile) (df152b3)
- [x] Task: Write widget tests for the preview integration (df152b3)

## Phase 4: Optimization & Polishing

- [x] Task: Optimize PDF generation for speed (e.g., using simpler preview logic if needed) (df152b3)
- [x] Task: Add subtle loading indicators for the preview (df152b3)
- [x] Task: Final verification and mobile polish (59e2b44)
