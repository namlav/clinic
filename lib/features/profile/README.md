# Profile Module

## Overview
The Profile module manages patient personal information, emergency contacts, and health insurance details. Provides both viewing and editing functionality for patient profile data.

## Components

### Views
- **ProfileScreen**: Displays patient profile information (read-only view)
  - Shows: Full name, email, phone, profile picture, edit button
  - Features: Loading state during data fetch, error handling
  
- **ProfileEditScreen**: Form for editing patient information
  - Sections: Personal info, emergency contact, health insurance
  - Features: Date pickers, dropdown for gender, form validation, save with loading indicator

### Models
- **PatientModel**: Core patient data model
  - Fields: id, fullName, email, phone, userId, profilePicture, createdAt
  - Methods: `fetch()` - queries users table, `fromJson()` - parses response
  
- **HealthInsuranceModel**: Insurance information
  - Fields: id, insuranceNumber, providerName, validUntil, patientId
  - Methods: `fetch()` - retrieves current insurance, `fromJson()` - parses response

## Features

### Profile Viewing
- Displays current patient information
- Shows profile picture with fallback
- Edit button provides access to form

### Profile Editing
- **Personal Information Form**:
  - Full Name, Email, Phone (required)
  - Address, Date of Birth, Gender (optional)
  
- **Emergency Contact Section**:
  - Contact name, phone number, relationship
  
- **Health Insurance Section**:
  - Insurance number, provider name, expiry date
  - Auto-populates from HealthInsurance.fetch()

## Form Validation
- Required fields: Full Name, Phone Number
- SnackBar feedback for validation errors
- Loading state prevents multiple submissions
- Mounted check before setState/navigation

## Data Persistence
```
User submits form
    ↓
Validation check (fullName, phone not empty)
    ↓
Supabase update on 'users' table
    ↓
Success/error SnackBar feedback
    ↓
Navigation back to ProfileScreen
```

## Error Handling
- Try-catch block for Supabase operations
- User-friendly error messages in SnackBar
- Auth check ensures userId exists before update
- Finally block ensures cleanup of loading state

## Widget Lifecycle
- All TextEditingControllers properly disposed in dispose()
- Mounted check prevents setState after navigation
- No memory leaks from listeners or subscriptions
- FutureBuilder handles async insurance data loading

## Key Design Decisions
1. **Form Validation**: Simple but effective (required fields only)
2. **Date Pickers**: Native Flutter date picker for consistent UX
3. **Gender Dropdown**: Predefined options (Nam/Nữ/Khác) with icons
4. **Direct Supabase Updates**: No service layer needed for simple updates
5. **Insurance Auto-Load**: HealthInsurance.fetch() populates insurance fields

## Future Improvements
- Save insurance data separately (currently display-only)
- Profile picture upload functionality
- Phone number format validation
- Field-level validation with real-time feedback
- Diagnosis and prescription information (requires backend support)
