# Implementation Plan - Real-time PDF Preview

This plan follows a TDD approach as defined in the project workflow.

## Phase 1: Research & Setup

- [x] Task: Research and add `syncfusion_flutter_pdfviewer` dependency (938fd7a)
- [x] Task: Evaluate performance of in-memory PDF generation for previews (Confirmed architecture supports Uint8List) (938fd7a)

## Phase 2: Preview Logic Implementation

- [x] Task: Update `PdfService` to return `Uint8List` for in-memory previews (Already supports Uint8List) (938fd7a)
- [~] Task: Implement debounced preview updates in `InvoiceProvider`
- [ ] Task: Write unit tests for the updated `InvoiceProvider` and `PdfService`

## Phase 3: UI Integration

- [ ] Task: Create `InvoicePreview` widget using `SfPdfViewer.memory`
- [ ] Task: Implement responsive layout (Side-by-side for desktop, Toggle for mobile)
- [ ] Task: Write widget tests for the preview integration

## Phase 4: Optimization & Polishing

- [ ] Task: Optimize PDF generation for speed (e.g., using simpler preview logic if needed)
- [ ] Task: Add subtle loading indicators for the preview
- [ ] Task: Final verification and mobile polish
