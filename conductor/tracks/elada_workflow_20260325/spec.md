# Specification - Elada Workflow Enhancements

## Overview
This track focuses on evolving Elada from a single-page generator into a more complete application. It introduces data management for past invoices and drafts, support for multiple currencies, and a clean navigation structure to switch between these views.

## User Stories
- **As a freelancer,** I want to see a history of all invoices I've generated so I can track my billings.
- **As a freelancer,** I want to save an invoice as a draft and finish it later so I don't lose my work if I'm interrupted.
- **As a freelancer,** I want to generate invoices in different currencies (€, $, £) to support international clients.
- **As a user,** I want an intuitive way to navigate between the generator and my history.

## Functional Requirements
- **Dashboard UI:**
    - List view of generated invoices (History).
    - Section for saved drafts.
    - Search/Filter by invoice number or description.
- **Draft Management:**
    - "Save as Draft" button in the Generator.
    - Ability to open a draft, which pre-fills the Generator with the saved data.
    - Delete drafts.
- **Multi-Currency Support:**
    - Currency selector (Dropdown or Toggle) in the Generator.
    - Persist the selected currency in the Invoice model and Hive.
    - Update the PDF generation logic to use the selected currency symbol.
- **Navigation:**
    - Implement a Bottom Navigation Bar with "Generate" and "History" tabs.
    - Smooth transitions between screens.

## Technical Constraints
- **State Management:** Extend `InvoiceProvider` to handle lists of history and drafts.
- **Storage:** Update `InvoiceRepository` to support CRUD operations for drafts and multi-currency settings.
- **UI:** Maintain the Minimalist Material 3 aesthetic.
- **Architecture:** Maintain MVVM/Clean principles.

## Visual Design
- **List Items:** Clean cards with subtle shadows and clear typography for totals and dates.
- **Navigation:** Modern Material 3 `NavigationBar`.
- **Empty States:** Beautifully illustrated or icon-based "No History" and "No Drafts" states.
