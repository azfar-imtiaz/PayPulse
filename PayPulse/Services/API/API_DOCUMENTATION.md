# PayPulse API Documentation

## Overview

The PayPulse API uses a unified, type-based approach that handles both rental and retail invoices through the same endpoints with different behaviors based on the invoice type.

**Base URL**: `https://6volksdhtf.execute-api.eu-west-1.amazonaws.com/v1`

---

## API Endpoints

### Invoice Ingestion (POST)

#### Ingest All Invoices
```
POST /v1/invoices/{type}/ingest
```

**Behavior by Type:**
- `type = "rental"` → Triggers `fetch_invoices` Lambda
- `type = "retail"` → Triggers `fetch_retail_invoices` Lambda

**Rental Request:**
```json
POST /v1/invoices/rental/ingest
```
No request body required.

**Retail Request:**
```json
POST /v1/invoices/retail/ingest
{
  "start_date": "2025-01-01",  // Optional
  "end_date": "2025-01-31"      // Optional
}
```

**Response:**
```json
{
  "message": "Success",
  "code": 200,
  "data": {
    "invoiceCount": 15
  }
}
```

---

#### Ingest Latest Invoice (Rental Only)
```
POST /v1/invoices/{type}/ingest/latest
```

**Note:** Only supported for `type = "rental"`. Retail invoices do NOT have a `/latest` endpoint.

**Request:**
```json
POST /v1/invoices/rental/ingest/latest
```
No request body required.

**Response Codes:**
- `200` - Invoice already exists for current month
- `201` - New invoice found and processed successfully
- `204` - Invoice not yet available for current month

**Response:**
```json
{
  "message": "Invoice already exists / Invoice processed / No invoice available",
  "code": 200 | 201 | 204,
  "data": null
}
```

---

### Invoice Retrieval (GET)

#### Get All Invoices by Type
```
GET /v1/invoices/{type}
```

Handled by single `get_invoices` Lambda for both rental and retail types.

---

#### Get Rental Invoices
```
GET /v1/invoices/rental
```

**Response Structure:**
```json
{
  "message": "Success",
  "code": 200,
  "data": {
    "invoiceCount": 12,
    "invoices": {
      "2025": [
        {
          "InvoiceID": "rental_invoice_123",
          "filename": "invoice_jan_2025.pdf",
          "hyra": 8500,
          "el": 450,
          "kallvatten": 120,
          "varmvatten": 230,
          "totalAmount": 9300,
          "dueDateMonth": "2",
          "dueDateYear": "2025",
          "dueDate": "2025-02-01",
          "moms": 0,
          "ocr": "123456789"
        }
      ],
      "2024": [...]
    }
  }
}
```

**Key Characteristics:**
- Returns **ALL fields** in list view (no separate detail call needed)
- Grouped by **year** (using `due_date_year`)
- Sorted **newest first** within each year
- All fields stored in single `RentalInvoices` table

---

#### Get Retail Invoices (All Sub-Types)
```
GET /v1/invoices/retail
```

**Response Structure:**
```json
{
  "message": "Success",
  "code": 200,
  "data": {
    "invoiceCount": 45,
    "invoices": {
      "food-delivery": [
        {
          "InvoiceID": "retail_invoice_123",
          "invoice_date": "2025-01-15",
          "total_amount": 250.50,
          "currency": "SEK",
          "vendor_name": "Dominos",
          "sub_type": "food-delivery"
        }
      ],
      "clothing": [...],
      "technology": [...],
      "subscriptions": [...],
      "grocery": [...],
      "utility": [...],
      "miscellaneous": [...],
      "travel": [...]
    }
  }
}
```

**Key Characteristics:**
- Returns **BASE fields only** (not detail fields)
- Grouped by **sub-type** (not by year)
- Sorted **newest first** within each sub-type (by `invoice_date`)
- Detail fields require separate API call

**Base Fields Returned:**
- `InvoiceID` - Unique invoice identifier
- `invoice_date` - Date of invoice/purchase
- `total_amount` - Total invoice amount
- `currency` - Currency code (e.g., "SEK", "USD")
- `vendor_name` - Name of vendor/merchant
- `sub_type` - Retail sub-type category

---

#### Get Retail Invoices by Sub-Type
```
GET /v1/invoices/retail?subtype={subtype}
```

**Supported Sub-Types:**
- `food-delivery`
- `clothing`
- `technology`
- `subscriptions`
- `grocery`
- `utility`
- `miscellaneous`
- `travel`

**Example Request:**
```
GET /v1/invoices/retail?subtype=food-delivery
```

**Response Structure:**
```json
{
  "message": "Success",
  "code": 200,
  "data": {
    "invoiceCount": 8,
    "invoices": {
      "food-delivery": [
        {
          "InvoiceID": "retail_invoice_123",
          "invoice_date": "2025-01-15",
          "total_amount": 250.50,
          "currency": "SEK",
          "vendor_name": "Dominos",
          "sub_type": "food-delivery"
        }
      ]
    }
  }
}
```

Returns only base fields for the specified sub-type.

---

#### Get Detailed Retail Invoice
```
GET /v1/invoices/retail?subtype={subtype}&invoice-id={invoice_id}
```

**Example Request:**
```
GET /v1/invoices/retail?subtype=food-delivery&invoice-id=retail_invoice_123
```

**Response Structure:**
```json
{
  "statusCode": 200,
  "body": {
    "message": "Retail food-delivery invoice details retrieved successfully!",
    "data": {
      "invoiceDetails": {
        "InvoiceID": "retail_invoice_123",
        "delivery_fee": 25.0,
        "items": [
          {
            "name": "Margherita Pizza",
            "description": "Extra cheese",
            "price": 120.0,
            "quantity": 1
          }
        ],
        "discount": 10.0
      }
    }
  }
}
```

**Important Notes:**
- Returns **ONLY detail table fields** (sub-type specific fields)
- Does **NOT** include base fields (vendor_name, total_amount, currency, etc.)
- Contains `InvoiceID` for reference
- Base and detail fields must be **merged on the client side**

---

#### Get Single Rental Invoice (Not Commonly Used)
```
GET /v1/invoices/rental/{invoice_id}
```

Currently only used for rental invoices. Returns complete invoice data for a single invoice.

---

## Retail Invoice Sub-Types

### 1. Food Delivery (`food-delivery`)
**Detail Table:** `FoodDeliveryInvoices`

**Detail Fields:**
- `delivery_fee` - Delivery charge
- `items` - Array of ordered items with name, description, price, quantity
- `discount` - Discount amount applied

---

### 2. Clothing (`clothing`)
**Detail Table:** `ClothingInvoices`

**Detail Fields:** (To be documented)

---

### 3. Technology (`technology`)
**Detail Table:** `TechnologyInvoices`

**Detail Fields:** (To be documented)

---

### 4. Subscriptions (`subscriptions`)
**Detail Table:** `SubscriptionInvoices`

**Detail Fields:** (To be documented)

---

### 5. Grocery (`grocery`)
**Detail Table:** `GroceryInvoices`

**Detail Fields:** (To be documented)

---

### 6. Utility (`utility`)
**Detail Table:** `MiscellaneousUtilityInvoices`

**Detail Fields:** (To be documented)

---

### 7. Miscellaneous (`miscellaneous`)
**Detail Table:** `MiscellaneousInvoices`

**Detail Fields:** (To be documented)

---

### 8. Travel (`travel`)
**Detail Table:** `TravelInvoices`

**Detail Fields:** (To be documented)

---

## Key Differences: Rental vs Retail

| Aspect | Rental Invoices | Retail Invoices |
|--------|----------------|-----------------|
| **Data Structure** | Single table, all fields | Two-tier: base + detail tables |
| **List Response** | All fields included | Base fields only |
| **Detail Access** | No separate call needed | Requires additional API call |
| **Grouping** | By year (`due_date_year`) | By sub-type |
| **Sorting** | Newest first within year | Newest first within sub-type |
| **Latest Endpoint** | ✅ Supported (`/ingest/latest`) | ❌ Not available |
| **Date Range Ingest** | ❌ Not supported | ✅ Supported (optional) |
| **Ingestion Source** | Single email source | Vendor-based patterns |

---

## Standard Response Format

All endpoints use the `APISuccessResponse` wrapper structure:

```json
{
  "message": "Success message",
  "code": 200,
  "data": {
    // Endpoint-specific data
  }
}
```

---

## Error Responses

Errors follow the `APIErrorResponse` structure:

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message"
  }
}
```

**Common Error Codes:**
- `INVALID_CREDENTIALS` - Invalid email or password
- `TOKEN_EXPIRED` - Session expired, re-authentication required
- `GMAIL_TOKEN_EXPIRED` - Gmail connection needs renewal
- `USER_NOT_FOUND` - User account not found
- `USER_ALREADY_EXISTS` - Account with email already exists
- `INVOICE_PARSE_ERROR` - Failed to parse invoice data
- `MISSING_FIELDS` - Required fields missing from request
- `INTERNAL_SERVER_ERROR` - Server-side error occurred

---

## Authentication

All invoice-related endpoints require authentication via Bearer token in the `Authorization` header:

```
Authorization: Bearer {access_token}
```

Tokens are managed by the `AuthManager` and automatically attached by `PayPulseAPIClient`.

---

## Client Usage Patterns

### Browsing Invoices
**Single API call** gets summary with base fields:
```swift
GET /v1/invoices/retail
// or
GET /v1/invoices/retail?subtype=food-delivery
```

### Viewing Invoice Details
**Separate API call** per invoice to get sub-type-specific fields:
```swift
GET /v1/invoices/retail?subtype=food-delivery&invoice-id=retail_invoice_123
```

Client must merge base fields (from list) with detail fields (from detail call) to display complete invoice information.

---

## Notes

- The API design optimizes for the common use case (browsing invoice lists) while allowing rich detail access when needed
- Retail invoice ingestion supports custom date ranges for flexible data retrieval
- Rental invoices are typically monthly recurring payments organized by time period
- Retail invoices are diverse purchases organized by category/sub-type
- Future retail sub-types can be added without changing the API structure

---

**Last Updated:** February 5, 2026
