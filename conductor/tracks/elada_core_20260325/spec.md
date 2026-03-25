# Specification - Elada Core Functionality

## Overview
This track focuses on building the foundational elements of the Elada invoice generator. It encompasses the ability to load a specific PDF template, inject dynamic data into designated fields, and provide a user-friendly interface for managing this process.

## User Stories
- **As a freelancer,** I want to input an item description and a total amount so that my invoice is generated correctly and professionally.
- **As a freelancer,** I want the system to remember my last invoice number and suggest the next one so that I don't have to track it manually.
- **As a freelancer,** I want to be able to override the suggested invoice number if I need to start a new sequence or correct a mistake.
- **As a freelancer,** I want a clean, minimalist UI that works on my phone so I can generate invoices on the go.

## Functional Requirements
- **PDF Template Loading:** Load the `Invoice-YONIK KOSHER LIFESTYLE.pdf` template from a known local path.
- **Field Mapping:** Identify and map the following fields in the PDF:
    - `INVOICE NO.`
    - `Description` (main item description area)
    - `Total` (subtotal and total area)
    - `Balance Due`
- **Dynamic Injection:** Replace the mapped fields with user-provided data using `syncfusion_flutter_pdf`.
- **Smart Numbering:**
    - Retrieve the last used invoice number from `hive` storage.
    - Increment by 1 for the default "next" number.
    - Provide an input field to override this value.
- **Single-Page UI:**
    - Input for Item Description.
    - Input for Total Amount (updates "Total" and "Balance Due" simultaneously).
    - Input for Invoice Number (pre-filled with the smart default).
    - "Generate PDF" button.
    - "Save as Draft" button.
- **File Generation:** Save the modified PDF to a user-specified location or a default "Generated Invoices" folder.

## Technical Constraints
- **Framework:** Flutter (Material 3).
- **PDF Library:** `syncfusion_flutter_pdf`.
- **Storage:** `hive` (NoSQL).
- **State Management:** `provider`.
- **Architecture:** Clean Architecture / MVVM.
- **Testing:** TDD approach with >80% coverage.

## Visual Design
- **Minimalist:** Clean lines, ample white space, high-quality typography (Roboto/Google Fonts).
- **Material 3:** Use `ColorScheme.fromSeed` for a cohesive color palette.
- **Feedback:** Real-time validation and toast notifications for success/failure.
