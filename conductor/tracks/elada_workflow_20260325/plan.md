# Implementation Plan - Elada Workflow Enhancements

This plan follows a TDD approach as defined in the project workflow.

## Phase 1: Data Layer & Provider Extensions

- [x] Task: Update Invoice Model and Repository for Drafts & Currency bcb7c02
    - [x] Update `Invoice` model to include a `isDraft` flag if needed, or create a separate `Draft` model.
    - [x] Update `InvoiceRepository` to manage a separate Hive box for drafts.
    - [x] Add methods to retrieve, delete, and update drafts.
    - [x] Write unit tests for updated repository logic.
- [ ] Task: Extend Invoice Provider for History and Multi-Currency
    - [ ] Implement `history` and `drafts` lists in `InvoiceProvider`.
    - [ ] Implement `selectedCurrency` state and toggle logic.
    - [ ] Implement `loadDraft` logic to populate input fields.
    - [ ] Write unit tests for new provider functionality.
- [ ] Task: Conductor - User Manual Verification 'Phase 1: Data Layer & Provider Extensions' (Protocol in workflow.md)

## Phase 2: Navigation & Dashboard UI

- [ ] Task: Implement Main Navigation Structure
    - [ ] Create `MainScreen` with `Scaffold` and `NavigationBar`.
    - [ ] Move `InvoiceScreen` to become a tab in `MainScreen`.
    - [ ] Create a placeholder `HistoryScreen`.
- [ ] Task: Implement History & Drafts List UI
    - [ ] Design and implement clean ListTiles/Cards for invoice history.
    - [ ] Implement the "No History" empty state.
    - [ ] Implement the list of drafts with "Edit" and "Delete" actions.
    - [ ] Write widget tests for the History screen.
- [ ] Task: Conductor - User Manual Verification 'Phase 2: Navigation & Dashboard UI' (Protocol in workflow.md)

## Phase 3: Generator Enhancements

- [ ] Task: Implement Multi-Currency Selector
    - [ ] Add a clean currency toggle/dropdown to `InvoiceScreen`.
    - [ ] Ensure the total input and PDF preview reflect the symbol.
- [ ] Task: Implement "Save as Draft" Logic
    - [ ] Connect the "Save as Draft" button to the provider.
    - [ ] Add a "Clear Form" button to reset the generator.
    - [ ] Verify persistence of drafts.
- [ ] Task: Update PDF Service for Currency
    - [ ] Pass the selected currency symbol to `PdfService`.
    - [ ] (Optional) Ensure the PDF template can handle the different symbols dynamically.
- [ ] Task: Conductor - User Manual Verification 'Phase 3: Generator Enhancements' (Protocol in workflow.md)

## Phase 4: Integration & Polishing

- [ ] Task: Final Integration & Regression Testing
    - [ ] Ensure full end-to-end flow: Draft -> Load -> Generate -> History.
    - [ ] Run full test suite and verify >80% coverage.
- [ ] Task: Mobile Polish & Performance
    - [ ] Refine list scrolling performance.
    - [ ] Add subtle entrance animations for list items.
- [ ] Task: Conductor - User Manual Verification 'Phase 4: Integration & Polishing' (Protocol in workflow.md)
