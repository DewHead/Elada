# Implementation Plan - Elada Core Functionality

This plan follows a TDD approach as defined in the project workflow.

## Phase 1: Project Scaffolding & Data Layer

- [x] Task: Initialize Flutter project and add core dependencies (4fe7cac)
    - [ ] Run `flutter create .`
    - [ ] Add `syncfusion_flutter_pdf`, `hive`, `hive_flutter`, `provider`, and `path_provider` to `pubspec.yaml`
    - [ ] Initialize `hive` in `main.dart`
- [~] Task: Implement Invoice Model and Local Storage (Hive)
    - [ ] Write tests for `Invoice` model and `InvoiceRepository`
    - [ ] Implement `Invoice` model with JSON serialization
    - [ ] Implement `InvoiceRepository` using `hive` to store the last invoice number and basic history
    - [ ] Verify 80% coverage for the data layer
- [ ] Task: Conductor - User Manual Verification 'Phase 1: Project Scaffolding & Data Layer' (Protocol in workflow.md)

## Phase 2: PDF Processing Logic

- [ ] Task: Implement PDF Service for Template Manipulation
    - [ ] Write tests for `PdfService` (mocking the PDF library if necessary)
    - [ ] Implement logic to load the asset template
    - [ ] Implement field mapping and injection for `description`, `total`, and `invoiceNumber`
    - [ ] Implement the PDF saving logic
    - [ ] Verify 80% coverage for `PdfService`
- [ ] Task: Conductor - User Manual Verification 'Phase 2: PDF Processing Logic' (Protocol in workflow.md)

## Phase 3: Business Logic & State Management

- [ ] Task: Implement Invoice Provider (State Management)
    - [ ] Write tests for `InvoiceProvider`
    - [ ] Implement state for current invoice inputs (description, total, number)
    - [ ] Implement logic for smart incrementing of invoice numbers
    - [ ] Connect `InvoiceProvider` to `PdfService` and `InvoiceRepository`
    - [ ] Verify 80% coverage for `InvoiceProvider`
- [ ] Task: Conductor - User Manual Verification 'Phase 3: Business Logic & State Management' (Protocol in workflow.md)

## Phase 4: Minimalist UI Implementation

- [ ] Task: Create Basic Layout and Input Fields
    - [ ] Write widget tests for the main screen
    - [ ] Implement Material 3 theme and basic scaffold
    - [ ] Add inputs for Description, Total, and Invoice Number
    - [ ] Implement real-time validation and auto-formatting for currency
- [ ] Task: Implement Action Buttons and Feedback
    - [ ] Write tests for button interactions
    - [ ] Connect "Generate PDF" button to `InvoiceProvider`
    - [ ] Implement "Save as Draft" functionality
    - [ ] Add success/error notifications (Snackbars)
- [ ] Task: Final Polishing & Mobile Optimization
    - [ ] Ensure responsive layout for different screen sizes
    - [ ] Add subtle animations and interactive "glow" effects
    - [ ] Final manual pass to ensure "bleeding edge" aesthetic
- [ ] Task: Conductor - User Manual Verification 'Phase 4: Minimalist UI Implementation' (Protocol in workflow.md)
