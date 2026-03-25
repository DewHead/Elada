# Implementation Plan - Elada Workflow Enhancements

This plan follows a TDD approach as defined in the project workflow.

## Phase 1: Data Layer & Provider Extensions [checkpoint: ae7c9f9]

- [x] Task: Update Invoice Model and Repository for Drafts & Currency bcb7c02
    - [x] Update `Invoice` model to include a `isDraft` flag if needed, or create a separate `Draft` model.
    - [x] Update `InvoiceRepository` to manage a separate Hive box for drafts.
    - [x] Add methods to retrieve, delete, and update drafts.
    - [x] Write unit tests for updated repository logic.
- [x] Task: Extend Invoice Provider for History and Multi-Currency 8ec6fa6
    - [x] Implement `history` and `drafts` lists in `InvoiceProvider`.
    - [x] Implement `selectedCurrency` state and toggle logic.
    - [x] Implement `loadDraft` logic to populate input fields.
    - [x] Write unit tests for new provider functionality.
- [x] Task: Conductor - User Manual Verification 'Phase 1: Data Layer & Provider Extensions' (Protocol in workflow.md) ae7c9f9

## Phase 2: Navigation & Dashboard UI [checkpoint: 7246acd]

- [x] Task: Implement Main Navigation Structure 4a94576
    - [x] Create `MainScreen` with `Scaffold` and `NavigationBar`.
    - [x] Move `InvoiceScreen` to become a tab in `MainScreen`.
    - [x] Create a placeholder `HistoryScreen`.
- [x] Task: Implement History & Drafts List UI d0e0d7f
    - [x] Design and implement clean ListTiles/Cards for invoice history.
    - [x] Implement the "No History" empty state.
    - [x] Implement the list of drafts with "Edit" and "Delete" actions.
    - [x] Write widget tests for the History screen.
- [x] Task: Conductor - User Manual Verification 'Phase 2: Navigation & Dashboard UI' (Protocol in workflow.md) 7246acd

## Phase 3: Generator Enhancements

- [x] Task: Implement Multi-Currency Selector 238c4cc
    - [x] Add a clean currency toggle/dropdown to `InvoiceScreen`.
    - [x] Ensure the total input and PDF preview reflect the symbol.
- [x] Task: Implement "Save as Draft" Logic 5f1bcc7
    - [x] Connect the "Save as Draft" button to the provider.
    - [x] Add a "Clear Form" button to reset the generator.
    - [x] Verify persistence of drafts.
- [x] Task: Update PDF Service for Currency 238c4cc
    - [x] Pass the selected currency symbol to `PdfService`.
    - [x] (Optional) Ensure the PDF template can handle the different symbols dynamically.
- [ ] Task: Conductor - User Manual Verification 'Phase 3: Generator Enhancements' (Protocol in workflow.md)

## Phase 4: Integration & Polishing

- [ ] Task: Final Integration & Regression Testing
    - [ ] Ensure full end-to-end flow: Draft -> Load -> Generate -> History.
    - [ ] Run full test suite and verify >80% coverage.
- [ ] Task: Mobile Polish & Performance
    - [ ] Refine list scrolling performance.
    - [ ] Add subtle entrance animations for list items.
- [ ] Task: Conductor - User Manual Verification 'Phase 4: Integration & Polishing' (Protocol in workflow.md)
