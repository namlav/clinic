# Appointment Module

## Overview
The Appointment module manages patient appointment history and details, including viewing past and upcoming appointments with associated appointment information (doctor, date, time, services).

## Components

### Views
- **AppointmentHistoryScreen**: Displays filterable list of appointments (Tất cả/Sắp tới/Hoàn thành)
  - Features: Real-time search, status filtering, navigation to detail
  - State: FutureBuilder with MedicalAppointment.fetch()
  
- **AppointmentDetailScreen**: Shows complete appointment information
  - Displays: Doctor info, appointment details, services provided
  - Handles: Null values with conditional rendering

### Models
- **MedicalAppointmentModel**: Represents appointment with medical details
  - Fields: id, appointmentDate, appointmentTime, status, serviceProvided, doctorId, doctorName, doctorSpecialization, hospitalName
  - Methods: 
    - `fetch()`: Queries appointments with doctor information
    - `fromJson()`: Parses API response into model
    - `toJson()`: Serializes model for updates

## Data Flow
```
Patient selects appointment from list
    ↓
GestureDetector triggers Navigator.push
    ↓
AppointmentDetailScreen receives appointment object
    ↓
Displays doctor info, appointment details, services
    ↓
User can navigate back via system back button
```

## API Integration
- Fetches from `appointments` table
- Joins with `doctors` table for doctor information
- Joins with `specialties` table for specialization info
- Requires Supabase authentication

## Key Design Decisions
1. **FutureBuilder Pattern**: Used for async data loading with proper loading/error states
2. **Null Safety**: All optional fields handled with null checks
3. **State Management**: Local setState for list filtering/search (no external providers)
4. **Navigation**: FadePageRoute for smooth screen transitions

## Error Handling
- FutureBuilder error state displays error message and icon
- Empty state shows "Không có cuộc khám nào" message
- Optional fields may be missing (handled gracefully)
